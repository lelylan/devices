require 'rubygems'
require 'spork'

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'
 
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models)
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  Spork.trap_method(Rails::Application, :eager_load!)
  
  require File.expand_path('../../config/environment', __FILE__)
  Rails.application.railties.all { |r| r.eager_load! }

  require 'rspec/rails'
  require 'capybara/rspec'
  require 'webmock/rspec'

  RSpec.configure do |config|
    config.mock_with :rspec

    # Clean up the database
    require 'database_cleaner'
    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.orm = 'mongoid'
    end

    config.before(:each) do
      DatabaseCleaner.clean
    end

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future rspec
    config.infer_base_class_for_anonymous_controllers = false
  end
end


# This code will be run each time you run your specs.
Spork.each_run do
  # Factory girl reload
  FactoryGirl.reload
  # I18n reload
  I18n.backend.reload!
  # Requires supporting ruby files with custom matchers and macros, etc.
  # Putting them in here we do load support file changes every time.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/requests/support/**/*.rb")].each {|f| require f}
end
