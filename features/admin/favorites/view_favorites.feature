@javascript
Feature: Admins can see favorites

Background:
  Given an "admin" account has been created
  And there are artists and art pieces with favorites
  And I login

Scenario: See the favorites
  When I click on "favorites" in the admin menu
  Then I see all the favorites in a table
