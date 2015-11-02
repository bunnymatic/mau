Feature: Manage Studios

As an administrator, I can update studios

Background:
  Given there are artists with art in the system
  And an "admin" account has been created
  And I login

Scenario: Showing the studios as an admin
  When I click on "studios" in the admin menu
  Then I see the admin studios list

Scenario: Updating a studio address
  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit the first studio
  And I change the street address to "100 market st"
  Then I see the first studio page
  And I see the first studio has the street address "100 market st"

Scenario: Removing an artist from a studio
  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit the first studio
  And I remove the first artist from the studio

  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit the first studio
  Then I see that artist is no longer part of the studio list
