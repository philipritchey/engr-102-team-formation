Feature: Create New Form
  As a professor
  I want to create a new form
  So that I can collect specific information from students

  Background:
    Given I am logged in as a professor
    And I navigate to my user profile page
    And I click on "Create New Form"

  Scenario: Professor successfully creates a new form
    When I fill in the form name with "New Test Form"
    And I fill in the form description with "This is a test form description"
    And I click "Create Form"
    Then I should be redirected to the form edit page
    And I should see options to add attributes to the form

  Scenario: Professor fails to create a form without a name
    When I fill in the form description with "This is a test form description"
    And I click "Create Form"
    Then I should see an error message "Name can't be blank"
    And I should remain on the new form page

  Scenario: Professor fails to create a form without a description
    When I fill in the form name with "New Test Form"
    And I click "Create Form"
    Then I should see an error message "Description can't be blank"
    And I should remain on the new form page

  Scenario: Professor fails to create a form with a duplicate name
    Given a form with the name "Existing Form" already exists
    When I fill in the form name with "Existing Form"
    And I fill in the form description with "This is a test form description"
    And I click "Create Form"
    Then I should see an error message "Name has already been taken"
    And I should remain on the new form page