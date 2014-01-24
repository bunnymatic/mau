Feature: As a user I can login

Background:
  Given an "admin" account has been created
  And there are artists with art in the system
  And there are tags on the art
  And I login

Scenario: login with good info
  When I click on "tags" in the admin menu
  Then I see the "admin tags" page
  When I destroy the first tag
  Then I see the most popular tag page
  And I don't see the first tag anymore
