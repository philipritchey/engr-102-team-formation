FactoryBot.define do
  factory :form do
    sequence(:name) { |n| "Test Form #{n}" }
    description { "This is a test form" }
  end
end
