Feature:

  Visitors can see artist's information and their art

Background:
  Given the following artists with art are in the system:
  | firstname | lastname   | nomdeplume |
  | joe       | bapple     |            |
  | mr        | bappleseed |            |
  | johnny    | tutone     |            |
  | mister    | mister     |            |
  And there are future open studios events

@javascript
Scenario:  Drilling down to an art piece page from the sampler
  When I visit the home page
  And I click on the first artist's card
  Then I see that artist's profile page
  When I click on an art card
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

  When I click on the first "artists" link
  And I click on "M"
  Then I see "mister mister"'s artist card


