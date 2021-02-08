@javascript
Feature: Artists Account
  As an artist
  I can see my page with my art and a menu of useful actions

Background:
  Given there are past open studios events
  And I login as an artist

Scenario: I can edit my profile even if i make a mistake
  When I visit my artist profile edit page
  Then I see my profile edit form

  When I click on "Personal Info"
  And I update my personal information with:
  | artist_email   |
  |                |
  And I click on "Save Changes"

  Then I see an error in the form "can't be blank"
