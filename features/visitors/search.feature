@javascript
Feature:
  Visitors can search for art

Background:
  Given the following artists with art are in the system:
  | firstname | lastname   | nomdeplume |
  | joe       | bapple     |            |
  | mr        | bappleseed |            |
  | johnny    | tutone     |            |
  | Alexander | Graham     |            |
  | mister    | mister     |            |

  Given there are open studios artists with art in the system

Scenario:  Visitors can search from the artists index page
  When I visit the home page
  And I click on "artists" in the ".sidenav"
  And I click on "search" in the ".main-container .search"
  Then I search for "bapple"
