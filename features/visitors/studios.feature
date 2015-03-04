Feature:

  Visitors can see studios


Background:
  Given there are artists with art in the system
  And there are open studios artists with art in the system

@javascript
Scenario:  I can drill into a studio detail
  When I visit the home page
  Then I click on "group studios"
  And I see the "Studios" page
  And I see that some studios are participating in open studios
  When I click on the first studio card
  Then I see the first studio page
