class GeekosSchema < GraphQL::Schema
  SCHEMA_FILE = Rails.root.join("app/graphql/schema.graphql")

  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
end
