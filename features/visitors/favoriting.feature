@javascript
Feature:

  Visitors can favorite an artist or their art

Background:
  Given the following artists with art are in the system:
  | firstname | lastname | nomdeplume | login       |
  | joe       | bapple   |            | joebapple   |
  | artist    | lover    |            | artistlover |
  And I visit the home page

Scenario:  I cannot favorite an artist if i'm not logged in
  And I click on "joe bapple"'s artist card
  And I click on "Add to your favorites"
  Then I see a flash notice including "have to login before"

Scenario:  I can favorite an artist once I've logged in
  When I login as "artistlover"
  And I click on "joe bapple"'s artist card
  And I click on the first "Add to your favorites"
  Then I see a flash notice including "has been added"
