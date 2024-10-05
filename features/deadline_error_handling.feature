Feature: Deadline Error Handling
  As a professor,
  So that I don’t accidentally set an invalid deadline,
  I want to receive an error message when selecting a past date for the deadline.

  Background:
    Given I am logged in as a professor
    And I have created a form

  Scenario: Professor attempts to set an invalid deadline (past date)
    When I visit the edit page for the form
    And I set the deadline to a past date and time
    And I click "Save Form"
    Then I should see an error message indicating "Deadline cannot be in the past"
    And the form should not be saved

