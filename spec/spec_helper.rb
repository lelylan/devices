ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

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

  config.after :each do
    User.destroy_all
  end

  # Load variables and settings shared around tests
  SETTINGS = HashWithIndifferentAccess.new(
    YAML.load_file("#{Rails.root}/spec/support/settings.yml")
  )
end
