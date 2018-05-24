Feature: Admin Application Events
  As an admin
  I can see all the application event sections

Background:
  Given the following admins are in the system:
  | login    |
  | billybob |
  Given the following artists with art are in the system:
  | login   |
  | whoever |

  And there are application events in the system
  When I visit the login page
  And I login as "billybob"

Scenario: Viewing and cleaning out tags
  When I click on "app events" in the admin menu
  Then I see all application events sections

@javascript
Scenario: Getting notified about user email changes
  Given I logout
  When I visit the login page
  When I login as "whoever"
  And I change my email to "new_email_address@example.com"

  Given I logout
  When I visit the login page
  When I login as "billybob"
  When I click on "app events" in the admin menu
  When I visit the home page
  And I click on "Something happened!"
  Then I see all application events sections
  And I see an email change in application events
