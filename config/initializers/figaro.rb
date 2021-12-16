# see all keys in config/application.yml
required_keys = %w[
  geekos_mongodb_server
]

# application.yml contains more keys, but not all of them are strictly mandatory
Figaro.require_keys(required_keys)
