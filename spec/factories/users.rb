FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Appliance.equipment }
    api_key { Faker::Alphanumeric.alphanumeric(number: 5, min_alpha: 3) }
  end
end
