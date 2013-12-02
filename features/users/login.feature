Feature: As a user I can login

Background:
  Given an account has been created
  Given I visit the login page

Scenario: login with bad info
  When I fill in an invalid username and password
  And I click "Log in"
  Then I see an error message "We had trouble signing you in"
