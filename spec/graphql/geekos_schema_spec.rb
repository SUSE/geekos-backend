require "rails_helper"

describe GeekosSchema do
  it 'current schema matches exported schema' do
    current_defn = described_class.to_definition
    printout_defn = File.read(GeekosSchema::SCHEMA_FILE)
    expect(current_defn).to eq(printout_defn)
  end
end
