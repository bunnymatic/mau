Feature:
  As an artist
  I can add art

Background:
  Given I login as an artist

Scenario: 
  When I visit my home page
  And I click on "manage art" in the sidebar menu
  And I fill out the add art form
  And I click "Add"

  Then I see that my art was added
  And I see my art

