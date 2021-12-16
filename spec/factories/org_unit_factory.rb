FactoryBot.define do
  factory :org_unit do
    depth { [1, 2, 3, 4].sample }

    after :create do |org_unit|
      org_unit.lead = create(:user, :ldap)
      org_unit.name = "#{FFaker::Name.first_name} unit"
      org_unit.short_description = FFaker::DizzleIpsum.phrase
      org_unit.description = FFaker::DizzleIpsum.phrases
      org_unit.save!
    end

    trait :with_children do
      after(:create) do |instance|
        instance.children << create(:org_unit)
        instance.children << create(:org_unit)
      end
    end
  end
end
