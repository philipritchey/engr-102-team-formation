Feature: Update Deadline from User Home Page
  As a professor,
  So that I can easily manage deadlines for my forms,
  I want to update the deadline for a form from my user profile page.

  Background:
    Given I am logged in as a professor
    And I have created a form with a set deadline

  Scenario: Update the deadline for a form from the user profile page
    When I navigate to my user profile page with set deadline
    Then I should see "Test Form with Deadline" in the list of forms for deadline management
    And I select a new future deadline for "Test Form with Deadline"
    When I click "Save" to save updated deadline for "Test Form with Deadline"
    Then the new deadline should be successfully saved
    And I should see the updated deadline on the user home page for "Test Form with Deadline"











