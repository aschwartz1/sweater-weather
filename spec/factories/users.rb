FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Appliance.equipment }

    trait :test do
      email { 'test@example.com' }
      password { 'password' }
    end
  end
end
