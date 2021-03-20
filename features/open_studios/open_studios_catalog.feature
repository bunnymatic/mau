@javascript
Feature: Open Studios Catalog
  As a visitor
  I can visit the main catalog page
  and any cms content that an admin might have added

Background:
  Given there are open studios artists with art in the system
  And the current open studios event has a special event
  And participating artists have filled out their open studios info form
  And there is open studios catalog cms content
  And I'm logged out

Scenario:
  When I visit "/" in the catalog
  Then I see pictures from all participating artists
  And I see the open studios catalog cms message

  When I click on the first artist's card
  Then I see that artist's open studios pieces
  And I see the artist's name in the header title
  And I see the summary information about that artists open studios events


Scenario: An artist sees their own pages
  Given the following artists with art are in the system:
    | login      | email              | number_of_art_pieces |
    | artist     | artist@example.com |                    1 |
  When I login as "artist"
  And I visit the open studios page
  And I click on "Artist Registration"

  Then I see my profile edit form

  When I click on "Yes - Register Me"
  And I click on "Yes" in the ".ReactModal__Content"
  Then I see the open studios info form
  And I see the "events" profile panel is open

  When I fill in the "#open_studios_info_form" form with:
    | shopUrl        | videoConferenceUrl |
    | https://www.rcode5.com  | https://www.youtube.com/watch?v=2SyPyBHJmiI |
  And I select every other time slot for the video conference schedule
  And I check "showEmail"
  And I check "showPhoneNumber"
  And I click on "Save"
  Then I see a flash notice "Got it"

  When I visit my open studios catalog page
  And I see the summary information about that artists open studios events
  And I see my video conference schedule
