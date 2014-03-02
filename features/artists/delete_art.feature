Feature:
  As an artist
  I can delete art

Background:
  Given I login as an artist

Scenario: 
  When I visit my home page
  And I click on "delete art" in the sidebar menu
  Then I can delete my art

  When I mark art for deletion
  Then I see that my art was deleted
  And I see my art

