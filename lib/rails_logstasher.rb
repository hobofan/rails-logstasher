require 'rails_logstasher/railtie' if defined?(Rails)
require 'rails_logstasher/rack/logger'
require 'rails_logstasher/event'
require 'logstash-event'
require 'rails_logstasher/logger'
require 'rails_logstasher/tagged_logging'

module RailsLogstasher

  class IncompatibleLogger < StandardError; end

  def self.log_entries
    @@events ||= {}
  end

end
