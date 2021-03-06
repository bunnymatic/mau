Feature: As a User I can view my own favorites and other users favorites
  Also, I can get guidance about how to find favorites
  Also, I can manage my favorites

Background:
  Given there are artists with art in the system

Scenario: Logged in as artist with favorites looking at other favorites
  When I login as an artist with favorites
  And I visit the favorites page for someone else
  Then I see someone else's favorites

Scenario: Logged in as artist with favorites looking at their own favorites
  When I login as an artist with favorites
  And I visit my favorites page
  Then I see my favorites

Scenario: Logged in as artist without favorites looking at other favorites
  When I login as an artist without favorites
  And I visit the favorites page for someone else
  Then I see someone else's favorites

Scenario: Logged in as artist without favorites looking at their own favorites
  When I login as an artist without favorites
  And I visit my favorites page
  Then I see my empty favorites page

@javascript
Scenario: I can remove favorites from my list
  When I login as an artist with favorites
  And I visit my favorites page
  And I remove the first favorite
  Then I see that I've lost one of my favorites
