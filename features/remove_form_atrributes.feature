Feature: Remove Specific Attributes
    As a professor
    So that I can enhance information collection
    I want to remove existing attributes from a form.

Background:
    Given I am logged in as a professor
    And I have created a form

Scenario: Professor removes an attribute from an existing form
    When I visit the edit page for the form
    Then I should see an option to add a new attribute
    When I enter "Programming Proficiency" as the attribute name
    And I select "Scale" as the attribute type
    And I enter "1" as the minimum value
    And I enter "8" as the maximum value
    And I submit the new attribute
    Then I should see "Programming Proficiency" listed as an attribute on the form
    When I click on "Destroy Attribute" for "Programming Proficiency" field
    Then I should not see "Programming Proficiency" in the current attributes