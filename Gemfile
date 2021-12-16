source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Core
gem 'bootsnap', require: false
gem 'puma'
gem 'rails', '~> 6.1.0'

# storage
gem 'mongoid'
gem 'mongoid-tree', require: 'mongoid/tree'

# Toppings
gem 'active_model_serializers'
gem 'awesome_print'
gem 'cancancan'
gem 'dragonfly'
gem 'figaro'
gem 'hashdiff'
gem 'hashie'
gem 'net-ldap'
gem 'oj'
gem 'openid_connect'
gem 'rack-cache', require: 'rack/cache'
gem 'rack-cors'
gem 'rest-client'
gem 'rubytree'
gem 'ruby-trello'

group :development do
  gem 'listen'
end

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails', require: false
  gem 'ffaker', require: false
  gem 'jsonlint', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-thread_safety', require: false
end

group :test do
  gem 'database_cleaner-mongoid'
  gem 'json_matchers'
  gem 'mongoid-rspec', github: 'mongoid-rspec/mongoid-rspec'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'timecop'
  gem 'webmock'
end
