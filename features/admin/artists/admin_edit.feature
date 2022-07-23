@javascript
Feature: Edit Artists' basic information

Background:
  Given there are artists with art in the system
  And there are future open studios events
  And there is a studio named "The Rock House"
  And an "admin" account has been created
  And I login
  When I click on "artists" in the admin menu
  And I see the admin artists list
  And I click on the first artist edit button that's not me

Scenario: Updating artists basic info
  When I fill in the form with:
  | Email                | Firstname      | Lastname      | Phone |
  | testdude@example.com | new first name | new last name | 4155551212 |
  And I click on "Update Artist"
  And I see the admin artist show page with updated values:
  | Email                | First Name     | Last Name     | Phone |
  | testdude@example.com | new first name | new last name | 415-555-1212 |

Scenario: Updating artist links
  When I fill in the form with:
  | artist_links_website | artist_links_facebook | artist_links_twitter | artist_links_blog | artist_links_pinterest | artist_links_myspace | artist_links_flickr | artist_links_instagram | artist_links_artspan |
  | http://website.c/x   | http://facebook.c/x   | http://twitter.c/x   | http://blog.c/x   | http://pinterest.c//x  | http://myspace.c/x/  | http://flickr.c/x   | http://instagram.c/x   | http://artspan.c/x   |
  And I click on "Update Artist"
  And I see the admin artist show page with updated values:
  | website            | facebook            | twitter            | blog            | pinterest             | myspace             | flickr            | instagram            | artspan            |
  | http://website.c/x | http://facebook.c/x | http://twitter.c/x | http://blog.c/x | http://pinterest.c//x | http://myspace.c/x/ | http://flickr.c/x | http://instagram.c/x | http://artspan.c/x |

Scenario: Updating artist links
  When I choose "The Rock House" from "Studio"
  And I click on "Update Artist"
  And I see that the admin artist pages shows that artist in studio "The Rock House"
Scenario: Updating artists open studios info
  Given the current open studios event has a special event
  And there is an open studios artist

  When I click on "artists" in the admin menu
  And I click on the first open studios artist edit button that's not me
  Then I see "OPEN STUDIOS INFO" on the page

  When I fill in "Shop url" with "http://buy.stuff.from.me/please"
  And I fill in "Video conference url" with "http://zoom.me/please"
  And I fill in "Youtube url" with "http://not.youtube.com/"
  And I click on "Update Artist"
  Then I see an inline form error "does not look like a Youtube link."

  When I fill in "Youtube url" with ""
  And I click on "Update Artist"

  Then I see "Open Studios Participant Information for" on the page

  And I see the admin artist show page with updated values:
    | Video Conference URL   | Shop URL                        |
    | http://zoom.me/please | http://buy.stuff.from.me/please |

  When I click on "edit artist"
  And as an admin I choose every other time slot for the video conference schedule
  And I click on "Update Artist"
  Then I see that the artist is scheduled for every other time slot


Scenario: Updating artist's profile picture
  When I go back
  And I click on the first artist show button that's not me
  Then I see that this artist has no profile picture
  And I attach a new profile image file
  And I click "Upload"
  Then I see the new profile image for that artist
