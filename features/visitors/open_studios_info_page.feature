Feature:

  Visitors to the open studios landing page 
  see a information about open studios
  so they can plan their visit

Background:
  Given there are open studios artists with art in the system
  And there is open studios cms content in the system
  And there is a scheduled Open Studios event

Scenario:  Visiting the open studios page
  When I visit the home page
  And I click on the current open studios link
  Then I see the open studios cms content
  And I see the open studios content is not editable

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
  And I take a screenshot
  And I click on the current open studios link
  Then I see the open studios cms mobile content

