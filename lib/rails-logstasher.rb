require 'rails-logstasher/railtie' if defined?(Rails)
require 'rails-logstasher/rack/logger'
require 'rails-logstasher/event'
require 'logstash-event'
require 'rails-logstasher/logger'
require 'rails-logstasher/tagged_logging'

module RailsLogstasher

  class IncompatibleLogger < StandardError; end

  def self.log_entries
    @@events ||= {}
  end

end
