@javascript
Feature: Admins can mange openstudios events
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

  When I fill in the open studios event form for next weekend with the title "SuperDuper"
  Then I see the open studios event with the title "SuperDuper"

  When I click delete on the "Open Studios" titled open studios event
  Then I see that the open studios event titled "Open Studios" is no longer there

  When I click on the first "clear os dates cache" button
  Then I see the "admin open studios events" page
  And I see a flash notice "cache has been cleared"

Scenario: Editing an existing open studios event
  When I click on "os dates" in the admin menu
  And I click on the last "Edit" link
  And I change the date to next month and the title to "Whatever"
  Then I see the open studios event with the title "Whatever"
