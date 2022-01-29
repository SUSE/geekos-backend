require "rails_helper"

describe GeekosSchema do
  it 'current schema matches exported schema' do
    current_defn = described_class.to_definition
    printout_defn = File.read(Rails.root.join("app/graphql/schema.graphql"))
    expect(current_defn).to eq(printout_defn)
  end
end
