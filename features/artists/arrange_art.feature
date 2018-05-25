Feature:
  As an artist
  I can arrange my art with a drag and drop

Background:
  Given I login as an artist

# javascript doesn't work in poltergeist :(
# https://github.com/jonleighton/poltergeist/issues/402
@javascript
Scenario:
  When I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click on "arrange"
  Then I can arrange my art

  When I move the last image to the first position
  And I visit my home page
  And I click on "My Art" in the sidebar menu
  And I click on "arrange"
  Then I see that my representative image has been updated
