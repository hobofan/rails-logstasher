$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails-logstasher/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-logstasher"
  s.version     = RailsLogstasher::VERSION
  s.authors     = ["Nadav Fischer"]
  s.email       = ["nadav.fischer@capriza.com"]
  s.homepage    = "https://github.com/capriza/rails-logstasher"
  s.summary     = "Lostash format replacement for Ruby on Rails logging system"
  s.description = "Replaces the default string based Ruby on Rails logging system with a Logstash based one"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
  s.add_dependency "logstash-event", "~> 1.2.02"

  s.add_development_dependency(%q<capybara>, ['~> 1.1.2'])
end
