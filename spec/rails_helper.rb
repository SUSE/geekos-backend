require 'simplecov'
require 'codecov'
# For some reason, when running in Github Actions it reports for 2 untested lines
# which is not reproducible locally.
SimpleCov.minimum_coverage 99
SimpleCov.start 'rails' do
  add_filter 'lib/ldap.rb'
  add_filter 'lib/crawler/delve.rb'
  add_filter 'lib/crawler/fuze.rb'
  add_filter 'lib/oic_client.rb'
  add_filter 'app/controllers/api/locations_controller.rb'
  add_filter 'app/controllers/api/rooms_controller.rb'
  # has generated environment specific code
  add_filter 'app/controllers/graphql_controller.rb'
  formatter(ENV['CI'] ? SimpleCov::Formatter::Codecov : SimpleCov::Formatter::HTMLFormatter)
end

ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
require 'spec_helper'
require 'rspec/rails'
require 'database_cleaner/mongoid'
require 'json_matchers/rspec'
require 'mongoid-rspec'
require 'ffaker'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Mongoid::Matchers, type: :model
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.cleaning do
      FactoryBot.lint
    end
    User.remove_indexes
    Tag.remove_indexes
    OrgUnit.remove_indexes
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
