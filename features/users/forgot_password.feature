Feature: As a user
  if i forget my password
  i can request a new one

Background:
  Given an account has been created
  Given I visit the login page
  And I click "Can't access your account?"

Scenario: try to reset with a known account
  When I fill in my email
  And I click "Submit"
  Then I see the login page
  And I see a flash notice "We've sent email"
