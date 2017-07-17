@javascript
Feature: Visitors to the open studios landing page
  see a list of participating artists
  so they can plan their visit

Background:
  Given there is a scheduled Open Studios event
  And there are open studios artists with art in the system
  When I visit the home page

Scenario:  Visiting the participants index page for open studios
  When I click on the current open studios link
  Then I wait "5" seconds
  Then I see the open studios page

  When I click on the open studios page "participants" tab
  Then I see only artist cards from artists that are doing open studios

  When I click on "map"
  Then I see a list of artists doing open studios with their studio addresses
  And a map of open studios participants

Scenario:  Visiting the open studios page as an editor
  When there are open studios artists with art in the system
  And there is open studios cms content in the system
  When I visit the home page
  And I click on the current open studios link
  Then I see the open studios page
