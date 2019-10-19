@javascript
Feature: View Artists

Background:
  Given there are artists with art in the system
  And there are not yet activated artists in the system
  And there are suspended artists in the system
  And there are future open studios events
  And an "admin" account has been created
  And I login

Scenario: Sort by different fields
  When I click on "artists" in the admin menu
  And I see the admin artists list
  And I see "In Good Standing (4)" on the page
  And I see "Not Yet Activated (2)" on the page
  And I see "Suspended etc. (2)" on the page
  And I see "never" on the page
  And I see "a few seconds ago" on the page

  When I click on the table header "Last seen"
  Then I see the first table row contains "never"
  And I see the last table row contains "minutes ago"

  When I click on the table header "Last seen"
  Then I see the first table row contains "minutes ago"
  And I see the last table row contains "never"
