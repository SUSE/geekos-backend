source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Core
gem 'awesome_print'
gem 'bootsnap', require: false
gem 'puma'
gem 'rails', '~> 6.1' # TODO: mongoid is not yet compatible with rails7

# storage
gem 'mongoid', '~> 7.3.3'
gem 'mongoid-audit_log'
gem 'mongoid-tree', require: 'mongoid/tree'

# api
gem 'active_model_serializers'
gem 'rack-cache', require: 'rack/cache'
gem 'rack-cors'

# config
gem 'figaro'

# crawlers
gem 'net-ldap'
gem 'oktakit'
gem 'rest-client'
gem 'rubytree'
gem 'ruby-trello'

# user pictures
gem 'dragonfly'

# login + permissions
gem 'cancancan'
gem 'openid_connect'

group :development do
  # watching for changed files
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
  gem 'hashie'
  gem 'json_matchers'
  gem 'mongoid-rspec', github: 'mongoid-rspec/mongoid-rspec'
  gem 'oj'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end
