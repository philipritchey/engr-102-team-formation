# This file defines factories for creating Attribute instances in tests
# It provides a default attribute factory and traits for different field types

FactoryBot.define do
  factory :attribute do
    # Associate each attribute with a form
    # This uses the form factory defined elsewhere
    form

    # Generate a unique name for each attribute
    # The sequence ensures each attribute has a different name
    sequence(:name) { |n| "Attribute #{n}" }

    # Set the default field type to "text_input"
    field_type { "text_input" }

    # Define a trait for scale-type attributes
    trait :scale do
      # Override the field_type for scale attributes
      field_type { "scale" }
      # Set default min and max values for the scale
      min_value { 1 }
      max_value { 10 }
    end

    # Define a trait for multiple-choice question (MCQ) attributes
    trait :mcq do
      # Override the field_type for MCQ attributes
      field_type { "mcq" }
      # Provide a default set of options for the MCQ
      options { "Option 1, Option 2, Option 3" }
    end
  end
end
