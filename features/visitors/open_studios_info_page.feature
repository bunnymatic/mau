Feature:

  Visitors to the open studios landing page 
  should see a information about open studios
  so they can plan their visit

Background:
  Given there are open studios artists with art in the system
  And there is open studios cms content in the system

Scenario:  Visiting the home page
  When I visit the home page
  And I click on "open studios" in the menu
  Then I should see the open studios cms content
  And I should see the open studios content is not editable

Scenario:  Visiting the home page as an editor
  Given I login as an editor
  When I visit the home page
  And I click on "open studios" in the menu
  Then I should see the open studios cms content
  And I should see the open studios content is editable
