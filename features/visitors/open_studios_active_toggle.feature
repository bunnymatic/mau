@javascript
Feature: Open Studios can be toggled by an admin
  When the admin turns the toggle on, open studios feature can be seen
  When it's off, open studios features are not visible

Background:
  Given there is a scheduled Open Studios event
  And there are open studios artists with art in the system
  And there is open studios cms content in the system
  When I visit the home page

Scenario:  Admin can toggle the Open Studios Active flag
  Then I see a "open studios" link
  And I see an open studios violator
  When I login as an admin
  And I visit the "edit admin site preferences" page
  And I toggle the open studios active toggle
  Then I see "new preferences are in place" on the page
  When I visit the home page
  Then I don't see the open studios navigation
  And I don't see any open studios violators
