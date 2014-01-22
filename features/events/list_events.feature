Feature: List events
  As a user, 
  I can see a list of MAU related events as a list and on a calendar
  so I can figure out what's super cool and how to engage with SF art and Artists
  
Background:
  Given there are events in the system
  And I visit the "events" page

Scenario: Go to the Events Page
  Then I see a list of events
  And I see a list of months and years for existing events
  
Scenario: Choose a month and year from the event nav
  When I click on the first month link
  Then I see the events for that month
  And I click on the calendar link
  Then I see the "calendar" page

