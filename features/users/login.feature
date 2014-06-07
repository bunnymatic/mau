Feature: As a user I can login

Background:
  Given an account has been created
  Given I visit the login page

Scenario: arriving on the page
  Then I do not see an error message

Scenario: login with bad info
  When I fill in an invalid username and password
  And I click "Sign In"
  Then I see an error message "That username/password combination is wrong."

Scenario: login with good info
  When I fill in valid credentials
  And I click "Sign In"
  Then I see that I'm logged in
