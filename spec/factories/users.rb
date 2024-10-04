FactoryBot.define do
    factory :user do
      sequence(:email) { |n| "user#{n}@example.com" }
      name { "Test User" }
      uin { "123456789" }
      # Add other necessary attributes
    end
  end
