Feature:

  Visitors can see artist's information and their art

Background:
  Given there are artists with art in the system
  And there are future open studios events

@javascript
Scenario:  Drilling down to an art piece page
  When I visit the home page
  And I click on an artists' page
  Then I see that artists profile page
  When I click on an art card
  And I see that art piece detail page
