Feature: As a user I can change my password

Background:
  Given an account has been created
  Given I visit the login page

Scenario: login with good info
  When I fill in valid credentials
  And I click "Sign In"
  And I click "edit my page"

  # And I change my password to "blahdeblah"
  # And I log out
  # And I visit the login page
  # And I fill in "blahdeblah" for my password
  # Then I see that I'm logged in

  
