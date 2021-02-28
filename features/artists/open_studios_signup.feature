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

  When I click on "Yes" in the ".ReactModal__Content"
  Then I see the open studios info form

Scenario: "when I'm logged in"
  When I login as "artist"
  And I visit the open studios page
  And I click on "Register to Participate"

  Then I see my profile edit form

  When I click on "Yes" in the ".ReactModal__Content"
  Then I see the open studios info form
  And I see the "events" profile panel is open

  When I fill in the "#open_studios_info_form" form with:
    | shopUrl        | videoConferenceUrl |
    | what | |
  And I click on "Update my details"
  Then I see a flash error "There was a problem"
  And I see "not a valid URL" on the page

  When I fill in the "#open_studios_info_form" form with:
    | shopUrl        | videoConferenceUrl |
    | https://www.rcode5.com  | https://www.youtube.com/watch?v=2SyPyBHJmiI |
  And I click on "Update my details"
  Then I see a flash notice "Got it"

  When I refresh the page
  And I open the "Open Studios" profile section
  Then I see the "#open_studios_info_form" form has:
    | shopUrl        | videoConferenceUrl |
    | https://www.rcode5.com  | https://www.youtube.com/watch?v=2SyPyBHJmiI |

  When I click on "Nope - not this time"
  Then I see a flash notice "Maybe next time! :\)"
  Then I see "Yes - Register Me" on the page


Scenario: "when I auto register but i'm not allowed (no address)"
  When I login as "no_address"
  And I visit the open studios page
  And I click on "Register to Participate"

  Then I see my profile edit form
  And I see the "events" profile panel is open
  And I see "Check the Address" on the page
