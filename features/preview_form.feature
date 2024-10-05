Feature: Preview Form

  Scenario: Professor previews the form
    Given I am logged in as professor
    And I have created a form with attributes for preview
    When I visit the edit page for the form to preview
    Then I should see a button to preview the form
    When I click the "Preview Form" button
    Then I should see the preview modal