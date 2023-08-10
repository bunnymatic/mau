Feature: Visitors can see studios

Background:
  Given there are future open studios events
  And there is a studio named "Rock And Roll Studio" with artists
  And there is a studio named "That Other Place" with artists
  And there are open studios artists with art in the system
  When I visit the home page
  And I wait until the page is done loading infinite scroll
  And I click on "group studios"

@javascript
Scenario:  I can drill into a studio detail
  Then I see the "Studios" page
  And I see that some studios are participating in open studios
  When I click on the first studio card
  Then I see the first studio page
  And I wait 3 seconds # clean up to avoid mysql transaction issues
