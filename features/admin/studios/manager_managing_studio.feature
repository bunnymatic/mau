@javascript
Feature: As a manager, I can manage my studio

Background:
  Given there are artists with art in the system
  When I login as a manager
  And there are artists with art in my studio
  When I click on "studios" in the admin menu
  Then I see the admin studios list
  Then I see update studio links for things I can manage

Scenario: Updating a studio address
  When I edit my studio
  And I change the street address to "100 market st"
  Then I see the studio page for me
  And I see the first studio has the street address "100 market st"

Scenario: Removing an artist from a studio
  When I edit my studio
  And I click on "Manage"
  And I remove the first artist from the studio
  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit my studio
  Then I see that artist is no longer part of the studio list
