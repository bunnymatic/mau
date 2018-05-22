Feature:  Visitors can see artist's information and their art

Background:
  Given the following artists with art are in the system:
  | firstname | lastname   | nomdeplume |
  | joe       | bapple     |            |
  | mr        | bappleseed |            |
  | johnny    | tutone     |            |
  | Alexander | Graham     |            |
  | mister    | mister     |            |
  And there are future open studios events

@javascript
Scenario:  Drilling down to an art piece page from the sampler
  When I visit the home page
  And I click on the first artist's card
  Then I see that artist's profile page
  And the meta description includes the artist's bio
  When I click on an art card
  And the meta description includes that art piece's title
  And the meta keywords includes that art piece's tags and medium
  And I see that art piece detail page

@javascript
Scenario:  Drilling down to an art piece page through the artists' index
  When I visit the home page
  And I click on the first "artists" link
  Then I see "joe bapple"'s artist card
  And I see "mr bappleseed"'s artist card
  When I click on "joe bapple"'s artist card
  Then I see that artist's profile page
  When I click on an art card
  And I see that art piece detail page

  When I click on "artists"
  And I click on "m" in the ".gallery-paginator"

  Then I see "mister mister"'s artist card

Scenario:  The artists index can be sorted by first name
  When I visit the home page
  And I click on the first "artists" link
  Then I see "joe bapple"'s artist card
  When I click on "organize by first name"
  Then I see "Alexander Graham"'s artist card

  When I click on "m" in the ".gallery-paginator"
  And I see "mr bappleseed"'s artist card
  And I see "mister mister"'s artist card
