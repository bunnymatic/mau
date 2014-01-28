Feature: Update Artists OS status

As an administrator, I can update artists status

As a studio manager, I can update artists' os status for artists in my building

Background:
  Given there are artists with art in the system
  And an "admin" account has been created
  And I login

Scenario: Showing the artists
  When I click on "artists" in the admin menu
  Then I see the admin artists list
