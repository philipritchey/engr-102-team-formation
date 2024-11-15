Feature: Validate file upload
  As a user
  I want to upload a valid file
  So that I can validate the file's content

  Background:
    Given I am logged in as a valid user with a form created
    And I am on the form view page

  Scenario: No file uploaded
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    When I submit the upload form without a file
    Then I should see "Please upload a file."
    And I should be redirected to my user profile page

  Scenario: First row is empty
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file with an empty first row
    When I submit the upload form
    Then I should see "The first row is empty. Please provide column names."
    And I should be redirected to my user profile page

  Scenario: Missing required columns
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file without 'Name', 'UIN', and 'Email ID' columns
    When I submit the upload form
    Then I should see "Invalid header. Please ensure the file contains 'Name', 'UIN', 'Email ID', and 'Section' columns."
    And I should be redirected to my user profile page

  Scenario: Missing name in a row
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file with missing name in a row
    When I submit the upload form
    Then I should see "Missing value in 'Name' column for row 2."
    And I should be redirected to my user profile page

  Scenario: Invalid UIN format
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file with an invalid UIN in a row
    When I submit the upload form
    Then I should see "Invalid UIN in 'UIN' column for row 2. It must be a 9-digit number."
    And I should be redirected to my user profile page

  Scenario: Missing email in a row
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file with missing email in a row
    When I submit the upload form
    Then I should see "Invalid email in 'Email ID' column for row 2."
    And I should be redirected to my user profile page

  Scenario: Invalid email format
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a file with an invalid email format in a row
    When I submit the upload form
    Then I should see "Invalid email in 'Email ID' column for row 2."
    And I should be redirected to my user profile page

  Scenario: Valid file upload
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a valid file
    When I submit the upload form
    Then I should see "All validations passed."
    And I should be redirected to my user profile page

  Scenario: xlsx file upload
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I have uploaded a xlsx valid file
    When I submit the upload form
    Then I should see "All validations passed."
    And I should be redirected to my user profile page

  Scenario: Download sample CSV file
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I am on the form home page
    When I click "Download Sample CSV" button
    Then the file "valid_file.csv" should be downloaded

  Scenario: Verify sample CSV file type
    Given I am on the form view page
    When I click the "Upload Students" button
    Then I should be redirected to the upload page
    Then I am on the form home page
    When I click "Download Sample CSV" button
    Then I should receive a file with type "text/csv"