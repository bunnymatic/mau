Feature:

  Visitors can see artist's information and their art

Background:
  Given there are artists with art in the system
  And there are future open studios events

@javascript
Scenario:  Drilling down to an art piece page from the sampler
  When I visit the home page
  And I click on the first artist's card
  And I see that art piece detail page

Scenario:  Drilling down to an art piece page through the artists' index
  When I visit the home page
  And I click on the first "artists" link
  And I click on the first artist's card
  Then I see that artist's profile page
  When I click on an art card
  And I take a screenshot
  And I see that art piece detail page
