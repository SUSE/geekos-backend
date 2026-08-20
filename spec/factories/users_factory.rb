FactoryBot.define do
  factory :user do
    coordinates { FFaker.numerify('49.######, 11.######') }
    notes { FFaker::Lorem.paragraph }

    transient do
      username { nil }
      employeenumber { nil }
    end

    after(:create) do |instance, evaluator|
      if evaluator.username
        instance.update(ldap: instance.ldap.update(samaccountname: evaluator.username),
                        suseid: instance.suseid.update(username: evaluator.username))
      end
      if evaluator.employeenumber
        instance.update(ldap: instance.ldap.update(employeenumber: evaluator.employeenumber),
                        suseid: instance.suseid.update(employeeNumber: evaluator.employeenumber))
      end
    end

    # The mapped attributes read from `suseid`, so a synced user carries both hashes
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

      suseid do
        { username: ldap['samaccountname'],
          employeeNumber: ldap['employeenumber'],
          email: ldap['mail'],
          telephoneNumber: ldap['telephonenumber'],
          country: ldap['co'],
          title: ldap['title'],
          name: ldap['displayname'],
          division: "#{FFaker::Name.first_name} division",
          date_joined: FFaker.numerify('201#-0#-1#T##:##:##.######Z') }.stringify_keys
      end
    end

    trait :okta do
      okta do
        { employeeStartDate: FFaker.numerify('201#-##-##') }.stringify_keys
      end
    end

    trait :root do
      username { Crawler::OrgTree::ROOT_USERNAME }
    end
  end
end
