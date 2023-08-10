Feature:  Visitors to the home page see
  a sampling of artists
  the new art that's been added to the system
  and a list of art related feeds.

  They should also see a banner talking about open studios and a menu of options to dig into seeing more artists


Background:
  Given there are artists with art in the system
  And there are future open studios events

@javascript
Scenario:  Visiting the home page
  When I visit the home page
  Then I see some of the art that's in the system
  And the page meta name "description" includes "Mission Artists is a website"
  And the page meta property "og:description" includes "Mission Artists is a website"
  And the page meta name "keywords" includes "art is the mission"
  And the page meta name "keywords" includes "artists"
  And the page meta name "keywords" includes "san francisco"
  And I can get to the about page from the footer
  And I can get to the privacy page from the footer
  And I can get to the contact page from the footer
  And I can send feedback via the footer link
  And I can see the credits from the footer link

@javascript
Scenario:  Visiting the home page when there is an active notification
  When there is an active notification
  And I visit the home page
  And wait until the page is done loading infinite scroll
  Then I see that notification
  And I wait 3 seconds # clean up to avoid mysql transaction issues
