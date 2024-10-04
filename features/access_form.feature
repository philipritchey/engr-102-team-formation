Feature: Access Form from User Home Page
  As a logged-in professor
  I want to access my forms from my home page
  So that I can manage my forms easily

  Background:
    Given I am logged in as a professor
    And I have created a form

  Scenario: View a form from the user home page
    When I navigate to my user profile page
    Then I should see "Test Form" in the list of forms
    When I click on "View" for "Test Form"
    Then I should be on the show page for "Test Form"
    And I should see the form details
