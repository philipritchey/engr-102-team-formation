# This file defines factories for creating Form instances in tests
# It provides a default form factory with associations and default values

FactoryBot.define do
  factory :form do
    # Associate each form with a user
    # This uses the user factory defined elsewhere
    user

    # Generate a unique name for each form
    # The sequence ensures each form has a different name
    sequence(:name) { |n| "Test Form #{n}" }

    # Set a default description for the form
    # This can be overridden in individual tests if needed
    description { "This is a test form" }
    # Set the published attribute to false by default
    published { false }

    # Note: You can add more attributes or traits here if needed
    # For example:
    # trait :with_attributes do
    #   after(:create) do |form|
    #     create_list(:attribute, 3, form: form)
    #   end
    # end
  end
end
