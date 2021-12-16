require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV['geekos_trello_key']
  config.member_token = ENV['geekos_trello_token']
end
