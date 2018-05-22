Feature: Visitors to the open studios landing page
  see a information about open studios
  so they can plan their visit

Background:
  Given there is a scheduled Open Studios event
  And there are open studios artists with art in the system
  And there is open studios cms content in the system

@javascript
Scenario:  Visiting the open studios page
  When I visit the home page
  And I click on the current open studios link
  Then I see the open studios cms content
  And I see the open studios content is not editable
  When I click on "participants"
  Then I see the open studios participants
  When I click on "map"
  Then I see a map of open studios participants

Scenario:  Visiting the open studios page as an editor
  Given I login as an editor
  When I visit the home page
  And I click on the current open studios link
  Then I see the open studios cms content
  And I see the open studios content is editable

@javascript
Scenario:  Visiting the open studios page on a phone
  When I'm on my smart phone
  And I visit the about page
  And I click on the current open studios link
  Then I see the open studios cms content
