source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '~> 3.2.6'
gem 'unicorn'
gem 'mongoid', '3.0.9' # TODO: from 3.0.10 I get some strange errors https://github.com/mongoid/mongoid/pull/2454
gem 'doorkeeper', '~> 0.6.1'
gem 'draper', '~> 0.15.0'
gem 'yajl-ruby'
gem 'rails_config'
gem 'addressable'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'bundler'
gem 'faraday'
gem 'dalli'
gem 'rails-api'
gem 'active_model_serializers', git: 'git://github.com/rails-api/active_model_serializers.git'

group :development, :test do
  gem 'foreman'
  gem 'rspec-rails', '~> 2.6'
  gem 'shoulda'
  gem 'capybara'
  gem 'capybara-json'
  gem 'factory_girl_rails', require: false
  gem 'database_cleaner'
  gem 'fuubar'
  gem 'spork', '~> 1.0rc'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'hashie'
  gem 'rails_best_practices'
  gem 'debugger'
end

group :test do
  gem 'webmock'
  gem 'growl'
  gem 'rb-fsevent'
  gem 'launchy'
end

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '~> 1.0.3'
end
