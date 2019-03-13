@javascript
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
  When I click on "studios" in the admin menu
  And I edit the first studio
  When I update the studio's latitude and longitude to "37.7623783" and "-122.4122675"
  Then I see the first studio page
  And I can tell the db knows the studio the latitude and longitude set to "37.7623783" and "-122.4122675"

Scenario: Removing an artist from a studio
  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit the first studio
  And I click on "Manage"
  And I remove the first artist from the studio

  When I click on "studios" in the admin menu
  Then I see the admin studios list
  When I edit the first studio
  Then I see that artist is no longer part of the studio list

Scenario: Adding a new studio
  When I click on "studios" in the admin menu
  And I click on "add studio"
  And I fill in the new studio information for "a new studio place thing"
  And I click on "Create Studio"
  Then I see there is a new studio called "a new studio place thing"

Scenario: Deleting a studio
  When I click on "studios" in the admin menu
  And I click on the last remove studio button
  Then I see the last studio has been removed
