source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.13'
gem 'rails-api'
gem 'mongoid', '~> 3.1.4'
gem 'doorkeeper'
gem 'unicorn'
gem 'draper'
gem 'yajl-ruby'
gem 'rails_config'
gem 'addressable'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bundler'
gem 'faraday'
gem 'dalli'
gem 'active_model_serializers', git: 'git://github.com/rails-api/active_model_serializers.git'
gem 'redis-throttle', git: 'git://github.com/andreareginato/redis-throttle.git'
gem 'rack-cors', require: 'rack/cors'
gem 'newrelic_rpm'

group :development, :test do
  gem 'foreman'
  gem 'rspec-rails', '~> 2.6'
  gem 'shoulda'
  gem 'capybara', '~> 1.1.4'
  gem 'capybara-json'
  gem 'mock_redis'
  gem 'factory_girl_rails', require: false
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'spork', '~> 1.0rc'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'hashie'
  gem 'rails_best_practices'
  gem 'debugger'
  gem 'brakeman', :require => false
end

group :test do
  gem 'webmock'
  gem 'growl'
  gem 'rb-fsevent'
  gem 'launchy'
end

group :production do
  gem 'rails_12factor'
end
