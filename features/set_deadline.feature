Feature: Set Deadline
  As a professor,
  So that I can enforce timely submissions,
  I want to set a deadline for form submissions.

  Background:
    Given I am logged in as a professor
    And I have created a form

  Scenario: Professor sets a valid deadline
    When I visit the edit page for the form
    And I set the deadline to a future date and time
    And I click "Save Form"
    Then the deadline should be successfully saved

