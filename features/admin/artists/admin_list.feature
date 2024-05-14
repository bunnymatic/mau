@javascript
Feature: Show Artists'

Background:
  Given there are future open studios events
  And there are artists with art in the system
  And there is a pending artist
  And there is a suspended artist
  And there is a studio named "The Rock House"
  And an "admin" account has been created
  And I login
  And I wait until the page is done loading infinite scroll

Scenario: List artists
  When I click on "artists" in the admin menu
  Then I see the admin artists list

  When I click on "Suspended"
  Then I see the suspended list

  When I click on "Not Yet Activated"
  Then I see the pending list