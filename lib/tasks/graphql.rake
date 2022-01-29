namespace :graphql do
  desc 'dump graphql schema'
  task export: :environment do
    # Get a string containing the definition in GraphQL IDL:
    schema_defn = GeekosSchema.to_definition
    # Choose a place to write the schema dump:
    schema_path = "app/graphql/schema.graphql"
    # Write the schema dump to that file:
    File.write(Rails.root.join(schema_path), schema_defn)
    puts "Updated #{schema_path}"
  end
end
