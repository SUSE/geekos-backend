class ApplicationController < ActionController::Base
  def index
    @graphql_schema = File.read(GeekosSchema::SCHEMA_FILE)
  end
end
