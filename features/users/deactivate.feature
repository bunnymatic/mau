Feature: As a user I can deactivate my account

Background:
  Given an account has been created
  And I visit the login page
  And I login

@javascript
Scenario: Deactivating my account
  When I click "edit my page"
  And I click on the last "change" button
  And I click "deactivate me"
  Then I see that I have been deactivated
