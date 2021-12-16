# to get info about db statements use
# `rake verbose db:create`

namespace :log do
  desc 'switch rails logger to stdout'
  task stdout: :environment do
    Rails.logger = Logger.new($stdout)
  end

  desc 'switch rails logger log level to info'
  task info: %i[environment stdout] do
    Rails.logger.level = Logger::INFO
  end

  desc 'switch rails logger log level to debug'
  task debug: %i[environment stdout] do
    Rails.logger.level = Logger::DEBUG
  end
end
