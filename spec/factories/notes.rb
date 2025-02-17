FactoryBot.define do
    factory :note do
      title { Faker::Lorem.sentence }
      content { Faker::Lorem.paragraph }
      color { 'blue' }
      archived { false }
      trashed { false }
      association :user
    end
  end
  