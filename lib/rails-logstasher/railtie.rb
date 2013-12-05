require 'rails-logstasher/core_ext/object/blank'
require 'rails-logstasher/action_controller/log_subscriber'
require 'rails-logstasher/action_view/log_subscriber'
require 'rails-logstasher/active_record/log_subscriber' if defined?(ActiveRecord)
require 'rails-logstasher/active_resource/log_subscriber' if defined?(ActiveResource)

module RailsLogstasher

  # Railtie to hook RailsLogstasher into Rails
  #
  # This Railtie hooks RailsLogstasher into Rails by adding middleware and loggers as well as
  # adding a completely new set of LogSubscribers which parallel the default rails ones but
  # are JSON based rather than string based
  class Railtie < Rails::Railtie

    initializer "rails-logstasher.swap_rack_logger_middleware" do |app|
      app.middleware.swap(Rails::Rack::Logger, RailsLogstasher::Rack::Logger, app.config.log_tags)
    end

    # Silence the asset logger. This has to be done in a before_initialize block because
    # the initializer is too late. (There might be a better part of the boot process for
    # this, keep an eye out)
    config.before_initialize do |app|
      app.config.assets.logger = false

      if app.config.logger.nil? && Rails.logger.class == ActiveSupport::TaggedLogging
        raise IncompatibleLogger, "Please replace the default rails logger (See the " +
                                  "Configuration section of the RailsLogstasher README)"
      end

      # Take the current logger and replace it with itself wrapped by the
      # RailsLogstasher::TaggedLogging class
      app.config.log_type = 'rails' unless app.config.respond_to? :log_type
      app.config.logger = RailsLogstasher::TaggedLogging.new(app.config.logger, app.config.log_type)
    end


    # We need to do the following in an after_initialize block to make sure we get all the
    # subscribers. Ideally rails would allow us the ability to stop the LogSubscribers from
    # registering themselves using a config option.
    config.after_initialize do

      # Kludge the removal of the default LogSubscribers for the moment. We will use the rails-logstasher
      # LogSubscribers (since they subscribe to the same hooks in the public methods) to create
      # a list of hooks we want to unsubscribe current subscribers from.
      modules = ["ActionController", "ActionView"]
      modules << "ActiveRecord" if defined?(ActiveRecord)
      modules << "ActiveResource" if defined?(ActiveResource)

      notifier = ActiveSupport::Notifications.notifier

      modules.each do |mod|
        "RailsLogstasher::#{mod}::LogSubscriber".constantize.instance_methods(false).each do |method|
          notifier.listeners_for("#{method}.#{mod.underscore}").each do |subscriber|
            ActiveSupport::Notifications.unsubscribe subscriber
          end
        end
      end

      # We then subscribe using the rails-logstasher versions of the default rails LogSubscribers
      RailsLogstasher::ActionController::LogSubscriber.attach_to :action_controller
      RailsLogstasher::ActionView::LogSubscriber.attach_to :action_view
      RailsLogstasher::ActiveRecord::LogSubscriber.attach_to :active_record if defined?(ActiveRecord)
      RailsLogstasher::ActiveResource::LogSubscriber.attach_to :active_resource if defined?(ActiveResource)

    end

  end

end
