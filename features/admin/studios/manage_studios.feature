Feature: Manage Studios

As an administrator, I can update studios

Background:
  Given there are artists with art in the system
  And an "admin" account has been created
  And I login

Scenario: Showing the studios
  When I click on "studios" in the admin menu
  Then I see the admin studios list

