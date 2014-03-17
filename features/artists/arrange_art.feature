Feature:
  As an artist
  I can arrange my art with a drag and drop

Background:
  Given I login as an artist

# javascript doesn't work :(
# https://github.com/jonleighton/poltergeist/issues/402
Scenario: 
  When I visit my home page
  And I click on "arrange art" in the sidebar menu
  Then I can arrange my art

  When I click on "cancel"
  Then I see my art
