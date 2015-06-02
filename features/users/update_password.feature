Feature: As a user I can change my password

Background:
  Given an account has been created
  Given I visit the login page

Scenario: login with good info
  When I fill in valid credentials
  And I click "Sign In"
  And I click on the first "My Profile" link


  
