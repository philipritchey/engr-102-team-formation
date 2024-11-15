Feature: Weightage Adjustment for Gender and Ethnicity Attributes
  As a professor creating a form
  I want gender and ethnicity attributes to be handled without weightage

  Background:
    Given I am logged in as a professor
    And I have created a form
    And I visit the edit page for the form

  Scenario: Adding gender attribute without weightage
    When I enter "Gender" as the attribute name
    And I select "Text" as the attribute type
    And I submit the new attribute
    Then I should see "Gender" listed as an attribute on the form
    And I should not see a weightage input field for the "Gender" attribute
    And the "Gender" attribute should be saved without a weightage value

  Scenario: Adding ethnicity attribute without weightage
    When I enter "Ethnicity" as the attribute name
    And I select "Text" as the attribute type
    And I submit the new attribute
    Then I should see "Ethnicity" listed as an attribute on the form
    And I should not see a weightage input field for the "Ethnicity" attribute