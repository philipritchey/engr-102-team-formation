Feature: Form Management

  Scenario: Professor creates a new form
    Given I am on the form management page
    When I click on "Create New Form"
    Then I should see a new form page
    When I fill in "Name" with "New Test Form"
    And I fill in "Description" with "This is a test form"
    And I click on "Create Form"
    Then I should be on the edit page for "New Test Form"
    And I should see a button to add attributes

  Scenario: Professor adds a scale attribute to a form
    Given I am on the edit page for "New Test Form"
    When I fill in "Attribute Name" with "Scale Question"
    And I select "Scale" from "Attribute Type"
    Then the scale fields should be visible
    And I fill in the min value with "1"
    And I fill in the max value with "10"
    And I click on "Save Attribute"
    Then I should see "Scale Question" in the list of current attributes
    And I should see "Min: 1, Max: 10" for "Scale Question"