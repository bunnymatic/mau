Feature:
  As an artist
  I can arrange my art with a drag and drop

Background:
  And I login as an artist

@javascript
Scenario: 
  When I visit my home page
  And I click on "arrange art" in the sidebar menu
  Then I can arrange my art

  When I rearrange my art with drag and drop
  Then I see the results are saved
