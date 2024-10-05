Feature: Form Responses
  As a professor,
  So that student information can be considered for team formation,
  I want student details to get saved in the database.

  Scenario: Store student responses in the database table
    Given I am logged in as a professor
    And I have created a form
    And I have added the following attributes to the form:
      | Name                   | Field Type    | Options                     | Min Value | Max Value |
      | Programming Experience | text_input    |                             |           |           |
      | Preferred Role         | mcq           | Developer,Tester,Designer   |           |           |
      | Teamwork Skills        | scale         |                             | 1         | 5         |
    When a student submits their UIN and responses
      | Attribute Name           | Response               |
      | Programming Experience   | 3 years of experience  |
      | Preferred Role           | Developer              |
      | Teamwork Skills          | 4                      |
    Then the response should be stored in the form_responses table
    And I should see a confirmation message "Response submitted successfully."