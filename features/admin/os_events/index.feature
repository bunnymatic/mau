Feature: 
  As an admin
  I can see all the open studios events in the system

Background:
  Given an "admin" account has been created
  And there are past open studios events
  And there are future open studios events
  And I login

Scenario: Viewing and cleaning out tags
  When I click on "os dates" in the admin menu
  Then I see the "admin open studios events" page
  And I see the open studios events
