@javascript
Feature:
  Visitors can search for art

Background:
  Given there are open studios artists with art in the system

Scenario:  Visitors can search from the artists index page
  When I visit the home page
  And I click on "artists" in the ".sidenav"
  And I click on "search" in the ".main-container .search"
  And I search for the first art piece by title
  Then I see the search results have the first art piece

Scenario:  Visitors can search for art by name
  When I visit the home page
  And I click on "search"
  And I search for the first art piece by title
  Then I see the search results have the first art piece

Scenario:  Visitors can search for art by artist name
  When I visit the home page
  And I click on "search"
  And I search for the first art piece by artist name
  Then I see the search results have the first art piece

Scenario:  Visitors can search using filters
  When I visit the home page
  And I click on "search"
  And I search for the first art piece by artist name
  Then I see the search results have the first art piece
  When I refine my search to ""
  And I click on "go"
  Then I see "search for something" on the page
  When I check the first media filter
  Then I see the search results have pieces from the first medium
  When I uncheck the first media filter
  When I check the first studio filter
  Then I see the search results have pieces from the first studio
  When I refine my search to "this will never match"
  And I click "go"
  Then I see the search results are empty

Scenario:  Visitors can search for art by open studios participants
  When I visit the "search" page
  And I refine my search to match lots of art
  And I choose "Yes" from "os_artist"
  And I click "go"
  Then I see the search results have only open studios participant art
