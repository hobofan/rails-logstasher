# RailsLogstasher

[![Build Status](https://secure.travis-ci.org/capriza/rails_logstasher.png)](http://travis-ci.org/capriza/rails_logstasher)
[![Coverage Status](https://coveralls.io/repos/capriza/rails_logstasher/badge.png?branch=master)](https://coveralls.io/r/capriza/rails_logstasher)
[![Code Climate](https://codeclimate.com/github/capriza/rails_logstasher.png)](https://codeclimate.com/github/capriza/rails_logstasher)
[![Dependency Status](https://gemnasium.com/capriza/rails_logstasher.png)](https://gemnasium.com/capriza/rails_logstasher)

Logstash Based Replacement logging system for Ruby on Rails.
This is a fork from https://github.com/rurounijones/yarder.

This gem will create JSON based log entries designed for consumption by Logstash version 1.2.
The JSON will contain the same information as can be found in the default rails logging output.

## Current Status

All logging in a Rails3 app should be JSON formatted, including ad-hoc logging.

RailsLogstasher has been tested against Rails 3.2.16 on Ruby 1.9.3.

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'rails_logstasher'
```

## Configuration

RailsLogstasher uses the Rails logger (set using config.logger in application.rb)to log output.

By default Rails uses the TaggedLogging class to provide this however because RailsLogstasher
replaces it you will need to change the default to something else.

You will need to specify a Ruby Logger compatible logger. RailsLogstasher provides its own
logger which is a copy of the ActiveSupport::Logger (Formerly known as
ActiveSupport::BufferedLogger)

If you are not sure what you want yet then set the RailsLogstasher::Logger as in the example
below in your application.rb file.

```ruby
module MyApp
  class Application < Rails::Application

    # Set a logger compatible with the standard ruby logger to be used by RailsLogstasher
    config.logger = RailsLogstasher::Logger.new(Rails.root.join('log',"#{Rails.env}.log").to_s)

  end
end
```

## Logstash Configuration

RailsLogstasher creates log entries with a default type of "rails", therefore your Logstash
configuration file should be as follows:

```
input {
  file {
    type => "rails"
    path => "/var/www/rails/application-1/log/production.log" # Path to your log file
    format => "json_event"
  }
}
```

The type can be configured via the application configuration "log_type" setting, like so:

```
module MyApp
  class Application < Rails::Application

    # Set a different type for the events
    config.log_type = 'my_type'

  end
end
```

You will need to edit the path to point to your application's log file. Because RailsLogstasher creates json
serialized Logstash::Event entries there is no need to setup any filters

### Known issues

RailsLogstasher currently creates nested JSON. Kibana has pretty good (With a few small UI problems) support
for nested JSON but logstash web does not.

## Developers

Thoughts, suggestions, opinions and contributions are welcome. 

When contributing please make sure to run your tests with warnings enabled and make sure that
rails_logstasher creates no warnings. (Warnings from other libraries like capybara etc. are ok)

```
RUBYOPT=-w rake
```


