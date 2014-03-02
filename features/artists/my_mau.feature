Feature:
  As an artist
  I can see my page with my art and a menu of useful actions

Background:
  Given I login as an artist

Scenario:
  When I visit my home page
  Then I see my art
  And I see my big thumbs on the left
  And I see the artist's menu

