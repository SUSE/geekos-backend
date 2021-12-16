require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret '5f7a84701dc0b70996738964a6eba696bcab589c34bc3698fb108c479a15cf6e'

  url_format '/media/:job/:name'

  datastore :file,
            root_path: Rails.root.join('public', 'system', 'dragonfly'),
            server_root: Rails.root.join('public')

  fetch_file_whitelist [
    /public/
  ]
  fetch_url_whitelist [
    /.*/
  ]
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
