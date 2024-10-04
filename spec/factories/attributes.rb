FactoryBot.define do
  factory :attribute do
    form
    sequence(:name) { |n| "Attribute #{n}" }
    field_type { "text_input" }

    trait :scale do
      field_type { "scale" }
      min_value { 1 }
      max_value { 10 }
    end

    trait :mcq do
      field_type { "mcq" }
      options { "Option 1, Option 2, Option 3" }
    end
  end
end
