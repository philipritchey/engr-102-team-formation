Feature: View Form Details
  As a professor
  I want to view my form details
  So that I can manage and monitor my forms

  Background:
    Given I log in as a professor

  Scenario: View an unpublished form
    Given I have created a form that is not published
    When I navigate to my user profile page
    And I click on "View" for "Test Form"
    Then I should see the form details
    And I should see "Edit this form" button
    And I should see "Publish Form" button
    And I should see "Destroy this form" button
    And I should see "This form is not published yet"

  Scenario: View a published form
    Given I have created a form that is published
    When I navigate to my user profile page
    And I click on "View" for "Test Form"
    Then I should see the form details
    And I should see "Close Form" button
    And I should not see "Edit this form" button
    And I should not see "Destroy this form" button
    And I should see "This form has been published. To make any changes, please close the form first"