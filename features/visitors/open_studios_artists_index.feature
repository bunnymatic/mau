Feature:
  Visitors to the open studios landing page 
  see a list of participating artists
  so they can plan their visit

Background:

Scenario:  Visiting the participants index page for open studios
  When I visit the home page
  And I click on the first "Open Studios" link
  Then I see the open studios page

Scenario:  Visiting the open studios page as an editor
  Given there is a scheduled Open Studios event
  And there are open studios artists with art in the system
  And there is open studios cms content in the system
  When I visit the home page
  And I click on the current open studios link
  Then I see the open studios page

