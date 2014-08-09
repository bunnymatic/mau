Feature:
  As an admin
  I can see all the application event sections

Background:
  Given an "admin" account has been created
  And there are application events in the system
  And I login

Scenario: Viewing and cleaning out tags
  When I click on "app events" in the admin menu
  Then I see all application events sections
