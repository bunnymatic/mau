@javascript
Feature:  Visitors can search for art

Background:
  Given the following artists with art are in the system:
  | firstname  | lastname   | nomdeplume |
  | joesephine | bapple     |            |
  | masterful  | bappleseed |            |
  | johnson    | tutone     |            |
  | Alexander  | Graham     |            |
  | misterful  | mister     |            |

  Given there are open studios artists with art in the system

Scenario:  Visitors can search from the artists index page by artist name or art piece name or studio name
  Given we've fixed the javascript issue that breaks this test
  When I visit the home page
  And I click on "artists" in the ".sidenav"
  And I click on "search" in the ".main-container .search"
  Then I search for "bapple"
  And I wait 1 second
  Then I see "bapple" in the search results

  When I visit the home page
  And I click on the first "search" link
  And I search for the first art piece by title
  And I wait 1 second
  Then I see the search results have the first art piece

  When I visit the home page
  And I click on the first "search" link
  And I search for the first art piece by artist name
  And I wait 1 second
  Then I see the search results have the first art piece

  # wait for ajax/search stuff to finish
  Then I wait "1" second
