Feature: Add Specific Attributes
  As a professor
  So that I can collect relevant information for team formation
  I want to add specific attributes to the form

  Background:
    Given I am logged in as a professor
    And I have created a form

  Scenario: Professor adds a specific attribute
    When I visit the edit page for the form
    Then I should see an option to add a new attribute
    When I enter "Programming Proficiency" as the attribute name
    And I select "Scale" as the attribute type
    And I enter "1" as the minimum value
    And I enter "8" as the maximum value
    And I submit the new attribute
    Then I should see "Programming Proficiency" listed as an attribute on the form
    
  Scenario: Attribute is saved to the database after submission
    When I visit the edit page for the form
    And I enter "Team Leadership" as the attribute name
    And I select "Scale" as the attribute type
    And I enter "1" as the minimum value
    And I enter "10" as the maximum value
    And I submit the new attribute
    Then the attribute "Team Leadership" should be saved in the database
    And the attribute "Team Leadership" should have a scale from 1 to 10