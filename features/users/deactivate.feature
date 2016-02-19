Feature: As a user I can deactivate my account

Background:
  Given an account has been created
  And I visit the login page
  And I login

@javascript
Scenario: Deactivating my account
  When I click "My Account"
  And I click "Deactivate"
  And I click "Deactivate"
  Then I see that I have been deactivated
