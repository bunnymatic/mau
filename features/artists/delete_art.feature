Feature: Removing Art
  As an artist
  I can delete art

Background:
  Given I login as an artist

Scenario:
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click on "remove"
  Then I can delete my art

  When I mark art for deletion
  Then I see that my art was deleted
  And I see my art
