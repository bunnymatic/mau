Feature:
  As an artist
  I can add and edit art

Background:
  Given I login as an artist

Scenario: 
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I fill out the add art form
  And I click "Add"

  Then I see that my art was added
  And I see my art

@javascript
Scenario: 
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click on "edit"
  And I click on the first "edit this art" button
  And I change "Title" to "Gobbledy Goop" in the ".art-piece-edit-form" form
  And I click "Update"
  Then I see that my art title was updated to "Gobbledy Goop"
  And I see a flash notice "art has been updated"


