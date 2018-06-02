@javascript
Feature: Open Studios Signup for Artists
  As an artist
  I have an easy way to get to sign up for open studios

Background:
  Given there is a scheduled Open Studios event
  Given the following artists with art are in the system:
    | login      | email              | number_of_art_pieces |
    | artist     | artist@example.com |                    1 |
  Given the following artists who aren't ready to sign up for os are in the system:
    | login      | email                  | number_of_art_pieces |
    | no_address | no_address@example.com |                    1 |
 Given I'm logged out

Scenario: "when I'm not logged in"
  When I visit the open studios page
  And I click on "Register to Participate"
  Then I see the login page

  When I fill in the login form with "artist/8characters"
  And I click on "Sign In"

  Then I see my profile edit form
  And I see the registration dialog

  When I click on "Yes"
  Then I see the update my registration message

Scenario: "when I'm logged in"
  When I login as "artist"
  And I visit the open studios page
  And I click on "Register to Participate"

  Then I see my profile edit form

  When I click "Yes" in the ".ngdialog"
  Then I see the update my registration message
  And I see the "events" profile panel is open

Scenario: "when I auto register but i'm not allowed (no address)"
  When I login as "no_address"
  And I visit the open studios page
  And I click on "Register to Participate"

  Then I see my profile edit form
  And I see the "events" profile panel is open
  And I see "Check the Address" on the page
