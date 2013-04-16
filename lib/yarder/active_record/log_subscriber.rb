require "securerandom"

module Yarder
  module ActiveRecord
    class LogSubscriber < ::ActiveSupport::LogSubscriber

      def self.runtime=(value)
        Thread.current["active_record_sql_runtime"] = value
      end

      def self.runtime
        Thread.current["active_record_sql_runtime"] ||= 0
      end

      def self.reset_runtime
        rt, self.runtime = runtime, 0
        rt
      end

      def initialize
        super
      end

      def sql(event)
        self.class.runtime += event.duration
        return unless logger.debug?

        payload = event.payload

        return if 'SCHEMA' == payload[:name]

        entry.fields['sql'] ||= []
        sql_entry = {}
        sql_entry['name'] = payload[:name]
        sql_entry['duration'] = event.duration
        sql_entry['sql']= payload[:sql].squeeze(' ')

        binds = nil

        unless (payload[:binds] || []).empty?
          binds = "  " + payload[:binds].map { |col,v|
            [col.name, v]
          }.inspect
        end

        sql_entry['binds'] = binds unless binds.nil?

        entry.fields['sql'] << sql_entry
        entry.write(false)
      end

      def identity(event)
        return unless logger.debug?

        payload = event.payload

        sql_entry = {}
        sql_entry['name'] = payload[:name]
        sql_entry['line'] = payload[:line]
        sql_entry['duration'] = payload[:duration]

        entry.fields['sql'] << sql_entry
        entry.write(false)
      end

    private

      def logger
        ::ActiveRecord::Base.logger
      end


      def entry
        unless Yarder.log_entries[Thread.current]
          entry = Yarder::Event.new(Rails.logger, false)
          entry.fields['uuid'] = SecureRandom.uuid
          #TODO Should really move this into the base logger
          entry.source = Socket.gethostname
          entry.type = "rails_json_log"
          Yarder.log_entries[Thread.current] = entry
        end
        Yarder.log_entries[Thread.current]
      end

    end
  end
end
