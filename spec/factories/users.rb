# This file defines factories for creating User instances in tests
# It provides a default user factory with unique email and UIN values

FactoryBot.define do
  factory :user do
    # Generate a unique email for each user
    # The sequence ensures each user has a different email address
    # Format: user1@example.com, user2@example.com, etc.
    sequence(:email) { |n| "user#{n}@example.com" }

    # Generate a unique UIN (University Identification Number) for each user
    # The sequence ensures each user has a different UIN
    # Format: UIN00001, UIN00002, etc. (padded to 5 digits)
    sequence(:uin) { |n| "UIN#{n.to_s.rjust(5, '0')}" }

    # Set a default name for all users
    # This can be overridden in individual tests if needed
    name { "John Doe" }

    # Note: You can add more attributes or traits here if needed
    # For example:
    # trait :admin do
    #   admin { true }
    # end
  end
end
