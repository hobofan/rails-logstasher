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

  # Options:
  # :entry_processor - a Proc to custom handle entries right before they are written to the log.
  #   RailsLogstasher.config[:entry_processor] = Proc.new {|entry| ... do stuff with entry ...}
  #
  def self.config
    @@config ||= {}
  end


end
