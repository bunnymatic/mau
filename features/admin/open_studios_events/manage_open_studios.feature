Feature: 
  As an admin
  I can see all the open studios events in the system

Background:
  Given an "admin" account has been created
  And there are past open studios events
  And there are future open studios events
  And I login

Scenario: Adding a new open studios event
  When I click on "os dates" in the admin menu
  Then I see the "admin open studios events" page
  And I see the open studios events
  When I click on "add new open studios date"
  Then I see a new open studios form

  When I fill in the open studios event form for next weekend
  Then I see a new open studios event

  When I click on the first "Delete" button
  Then I see that the new open studios event is no longer there

