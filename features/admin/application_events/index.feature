@javascript
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
  When I login as "billybob"

Scenario: Checking on application events
  When I visit "/admin/application_events"
  Then I see all application events sections
  And I see "(100 records)" on the page
  When I choose "200" from "Number of records"
  And I click "Query"
  Then I see all application events sections
  And I see "(200 records)" on the page
  When I fill in "Since" with "10202018\n"
  # capybara doesn't trigger change event on date inputs so manually set records to 0
  And I choose "" from "Number of records"
  And I click "Query"
  Then I see all application events sections
  And I see "(Since 2018-10-20)" on the page

Scenario: Getting notified about user email changes
  Given I'm logged out
  When I login as "whoever"
  And I change my email to "new_email_address@example.com"

  Given I logout
  When I login as "billybob"
  When I visit "/admin/application_events"
  And I wait "1" second
  When I visit the home page
  And I click on "Something happened!"
  Then I see all application events sections
  And I see an email change in application events
