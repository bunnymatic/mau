Feature:

  Visitors to the home page should see a sampling of artists, the new art that's been added to the system
  and a list of art related feeds. 

  They should also see a banner talking about open studios and a menu of options to dig into seeing more artists


Background:
  Given there are artists with art in the system

Scenario:  Visiting the home page
  When I visit the home page
  Then I should see some of the art that's in the system
  And I should see art newly added to the system
