Feature: Manage Studios

As an administrator, I can update studios

Background:
  Given there are artists with art in the system

Scenario: Showing the studios as an admin
  Given an "admin" account has been created
  And I login
  When I click on "studios" in the admin menu
  Then I see the admin studios list

Scenario: Showing the studios as an admin
  When I login as a manager
  When I click on "studios" in the admin menu
  Then I see update studio links for things i can manage




