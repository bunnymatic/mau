@javascript
Feature: Edit Artists' basic information

As an administrator, I can edit an artist's info

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
  | Email                | Firstname      | Lastname      |
  | testdude@example.com | new first name | new last name |
  And I click on "Update Artist"
  And I see the admin artist show page with updated values:
  | Email                | First Name     | Last Name     |
  | testdude@example.com | new first name | new last name |

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
