<<<<<<< HEAD
require 'rubygems'
require 'spork'

# Loading more in this block will cause your tests to run faster. However,
# if you change any configuration or code from libraries loaded here, you'll
# need to restart spork for it take effect.
Spork.prefork do
  ENV['RAILS_ENV'] ||= 'test'
 
  # Mongoid models reload
  require "rails/mongoid"
  Spork.trap_class_method(Rails::Mongoid, :load_models)
  # Routes and app/ classes reload
  require "rails/application"
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)
  Spork.trap_method(Rails::Application, :eager_load!)
  # Load railties
  require File.expand_path('../../config/environment', __FILE__)
  Rails.application.railties.all { |r| r.eager_load! }

  require 'rspec/rails'
  require 'capybara/rspec'
  require 'webmock/rspec'
  require 'draper/rspec_integration'

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

    config.alias_it_should_behave_like_to :it_validates, "it validates"

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
=======
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Webmock stubbing inclusion
require 'webmock'
include WebMock::API

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # Mock library
  config.mock_with :rspec

  # Cleaning up MongoDB after specs have ben executed
  config.after :suite do
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  # Clean user definition after every test
  config.after :each do
    User.destroy_all
  end
>>>>>>> a94ab928ffed209bca7c3d87982a12be9974a750
end
