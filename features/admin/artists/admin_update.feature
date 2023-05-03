@javascript
Feature: Update Artists status and os participation

As an administrator, I can update artists status

As a studio manager, I can update artists' os status for artists in my building

Background:
  Given there are artists with art in the system
  Given there are future open studios events
  And an "admin" account has been created
  And I login
  When I click on "artists" in the admin menu
  And I see the admin artists list

Scenario: Showing the artists
  And I see everyone who is "pending"
  And I see everyone who is "suspended"
  And I see everyone who is "deleted"

Scenario: Setting open studios for artists
  When I set all artists to do open studios
  Then I see that all artists are doing open studios
  And I see the admin artists list
  And I close the flash

  When I uncheck the box for the first participating artist
  Then I see that the first participating artist is no longer doing open studios

  When I visit the "Admin Os Status" page
  Then I see stars for all open studios participants

Scenario: Suspending artists
  When I suspend the first artist
  And I see a flash notice "has been suspended"
  And I close the flash
  And I click on "suspended"
  Then I see the first artist in that table

  When I reactivate the first artist
  Then I see a flash notice including "has been reactivated"
  And I see the first artist in that table
