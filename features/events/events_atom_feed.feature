Feature: List events
  As a user, 
  I can get a feed of MAU Related events
  so I can figure out what's super cool and how to engage with SF art and Artists with my Feed Reader
  
Background:
  Given there are events in the system
  And I visit "/events.atom"

Scenario: Go to the Events Feed
  Then I see a list of events
  And I see a list of months and years for existing events
  
Scenario: Choose a month and year from the event nav
  When I click on the first month link
  Then I see the events for that month
  And I click on the calendar link
  Then I see the "calendar" page

