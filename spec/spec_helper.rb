require 'rubygems'
require 'spork'

# This code runs once when you run your test suite
Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'

  # Rate limit fake redis connection
  require 'rack/redis_throttle/testing/connection'

  # Mongoid models reload
  require 'rails/mongoid'
  Spork.trap_class_method(Rails::Mongoid, :load_models)

  # Routes and app/ classes reload
  require 'rails/application'
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  Spork.trap_method(Rails::Application, :eager_load!)

  # Load railties
  require File.expand_path('../../config/environment', __FILE__)
  Rails.application.railties.all { |r| r.eager_load! }

  # General require
  require 'rspec/rails'
  require 'capybara/rspec'
  require 'webmock/rspec'
  require 'draper/test/rspec_integration'
  require 'database_cleaner'

  RSpec.configure do |config|
    config.mock_with :rspec

    # Clean up the database
    config.before(:suite) { DatabaseCleaner.strategy = :truncation }
    config.before(:suite) { DatabaseCleaner.orm      = :mongoid }
    config.before(:each)  { DatabaseCleaner.clean }
  end
end

# This code will be run each time you run your specs.
Spork.each_run do
  require 'factory_girl_rails'
  FactoryGirl.reload
  I18n.backend.reload!
  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
  Dir[Rails.root.join('spec/views/**/*.rb')].each   {|f| require f}
  Dir[Rails.root.join('lib/**/*.rb')].each          {|f| require f}
end
