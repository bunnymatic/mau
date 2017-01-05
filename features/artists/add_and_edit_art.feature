@javascript
Feature:
  As an artist
  I can add and edit art

Background:
  Given I login as an artist

Scenario: "Adding Art"
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I fill out the add art form
  And I click "Add"

  Then I see that my art was added
  And I see my art

Scenario: "Adding Art with invalid params"
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click "Add"
  Then I see that my art was not added

Scenario: "Editing Art"
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click on "edit"
  And I click on the first "edit this art" button
  And I change "Title" to "Gobbledy Goop" in the ".art-piece-edit-form" form
  And I update the art piece tags to:
    | new tag | other tag |
  And I save a screenshot
  And I click "Update"
  Then I see that my art title was updated to "Gobbledy Goop"
  And I save a screenshot
  And I see that my art tags are:
    | new tag | other tag |
  And I see a flash notice "art has been updated"
