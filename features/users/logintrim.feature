Feature: As a user I can login

Background:
  Given an account has been created
  Given I visit the login page

# @wip
# Scenario: login with good info

#   And show me the database cleaner strategy
#   # When I see how much data is in the system
#   When I fill in valid credentials
#   And I click "Sign In"
#   Then I see that I'm logged in
#   And I click on the first "sign out" link
#   Then I see that I'm logged out

@javascript
Scenario: login with good info
  # When I see how much data is in the system
  # And I log the js console
  When I fill in valid credentials
  # When I see how much data is in the system
  # And I log the js console
  And I click "Sign In"
  # When I see how much data is in the system
  # And I log the js console
  Then I see that I'm logged in
  # And I log the js console
  And I click on the first "sign out" link
  Then I see that I'm logged out
