Feature: List events
  As a user, 
  I can get a feed of MAU Related events
  so I can figure out what's super cool and how to engage with SF art and Artists with my Feed Reader
  
Background:
  Given there are events in the system
  And I visit "/events.atom"

Scenario: Go to the Events Feed
  Then I see a feed of events
