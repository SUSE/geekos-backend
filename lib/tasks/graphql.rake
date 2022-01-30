namespace :graphql do
  desc 'dump graphql schema'
  task export: :environment do
    # Get a string containing the definition in GraphQL IDL:
    schema_defn = GeekosSchema.to_definition
    # Write the schema dump to that file:
    File.write(GeekosSchema::SCHEMA_FILE, schema_defn)
    puts "Updated #{GeekosSchema::SCHEMA_FILE}"
  end
end
