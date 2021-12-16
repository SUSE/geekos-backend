require 'rails_helper'

describe Tag do
  it { is_expected.to be_mongoid_document }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of :name }
  it { is_expected.to have_timestamps }
end
