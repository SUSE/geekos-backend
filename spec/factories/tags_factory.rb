FactoryBot.define do
  factory :tag, class: 'Tag' do
    sequence(:name) { |n| "#{FFaker::Tweet.tags(1)[1..]} #{n}" }
  end
end
