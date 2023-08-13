@javascript
Feature: Admin can update an art piece
  I navigate directly to an art piece page and update the image

Background:
  Given an "admin" account has been created
  And there are artists with art in the system
  And I login

Scenario: Admin updates an art piece
  When I wait until the page is done loading infinite scroll
  When I navigate to the first art piece admin edit path
  Then I see the edit admin art piece page
  When I add a new file
  And I click "Upload"
  Then I see the edit admin art piece page
  And I see the new image
