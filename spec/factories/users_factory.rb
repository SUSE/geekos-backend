FactoryBot.define do
  factory :user do
    coordinates { FFaker.numerify('49.######, 11.######') }
    notes { FFaker::Lorem.paragraph }

    transient do
      username { nil }
      employeenumber { nil }
    end

    after(:create) do |instance, evaluator|
      instance.update(ldap: instance.ldap.update(samaccountname: evaluator.username)) if evaluator.username
      instance.update(ldap: instance.ldap.update(employeenumber: evaluator.employeenumber)) if evaluator.employeenumber
    end

    trait :ldap do
      ldap do
        { samaccountname: FFaker::Name.first_name,
          employeenumber: FFaker.numerify('######'),
          mail: FFaker::Internet.email,
          telephonenumber: FFaker::PhoneNumberDE.international_mobile_phone_number,
          co: FFaker::Address.country_code,
          title: FFaker::Book.title,
          displayname: "#{FFaker::Name.first_name} #{FFaker::Name.last_name}",
          cn: 'de' }.stringify_keys
      end
    end

    trait :okta do
      okta do
        { employeeStartDate: FFaker.numerify('201#-##-##') }.stringify_keys
      end
    end

    trait :root do
      after(:create) do |instance|
        instance.update(ldap: instance.ldap.update(samaccountname: Crawler::OrgTree::ROOT_USERNAME))
      end
    end
  end
end
