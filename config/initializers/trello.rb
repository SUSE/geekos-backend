require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV.fetch('geekos_trello_key', nil)
  config.member_token = ENV.fetch('geekos_trello_token', nil)
end
