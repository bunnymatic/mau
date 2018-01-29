@javascript
Feature:

  Visitors can see artist's information and their art

Background:
  Given there are artists with art in the system
  And there are tags on the art
  And I visit the home page
  And I click on the first artist's card
  And I click on an art card

Scenario:  Drilling down to an art piece tag
  Then I click on the first tag
  And I see that tag detail page

Scenario:  Drilling down to a medium through an artist page
  Then I click on the first medium
  And I see that medium detail page
