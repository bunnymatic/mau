@javascript
Feature: Personal Open Studios Page for an artist
  As a visitor
  I can visit an artist's custom open studios page

Background:
  Given there are open studios artists with art in the system
  Given I'm logged out

Scenario: "I can visit an artist's open studios page page directly"
  # As we do more we should navigate to here through the site
  # not with a direct visit.  But currently this link is "dark"
  # so we can test it this way for now.
  When I visit the first artist's open studios page
  Then I see that artist's open studios pieces
