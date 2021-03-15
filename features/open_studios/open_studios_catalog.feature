@javascript
Feature: Open Studios Catalog
  As a visitor
  I can visit the main catalog page
  and any cms content that an admin might have added

Background:
  Given there are open studios artists with art in the system
  And I'm on the subdomain "openstudios"
  And there is open studios catalog cms content
  And I'm logged out

Scenario:
  When I visit "/"
  Then I see pictures from all participating artists
  And I see the open studios catalog cms message

  When I click on the first artist's card
  Then I see that artist's open studios pieces
