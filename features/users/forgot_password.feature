Feature: Users' Password Management
  if i forget my password
  i can request a new one

Background:
  Given an account has been created
  Given I visit the login page
  And I click "Can't log in? Forgot your password?"

Scenario: try to reset with a known account
  When I fill in my email
  And I click "Submit"
  Then I see the login page
  And I see a flash notice "We've sent email"

  When I click on the reset link in my email
  And I set my new password to "the-long-pass"
  And I sign in with password "the-long-pass"
  Then I see that I'm logged in

Scenario: try to reset with a bogus reset code
  When I visit a reset link with an unknown reset code
  Then I see an error message "Are you sure you got the right link"
  And I see that I'm logged out
