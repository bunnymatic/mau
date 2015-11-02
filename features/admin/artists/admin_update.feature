Feature: Update Artists OS status

As an administrator, I can update artists status

As a studio manager, I can update artists' os status for artists in my building

Background:
  Given there are artists with art in the system
  Given there are future open studios events
  And an "admin" account has been created
  And I login
  When I click on "artists" in the admin menu

Scenario: Showing the artists
  Then I see the admin artists list
  And I see everyone who is "pending"
  And I see everyone who is "suspended"
  And I see everyone who is "deleted"


Scenario: Setting open studios for artists
  When I set all artists to do open studios
  Then I see that all artists are doing open studios
  And I see the admin artists list

  When I uncheck the box for the first participating artist
  Then I see that the first participating artist is no longer doing open studios

Scenario: Suspending artists
  When I click on "artists" in the admin menu
  Then I see the admin artists list

  When I suspend the first artist
  Then I see that the first artist is suspended
