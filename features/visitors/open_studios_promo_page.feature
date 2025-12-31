Feature: Visitors to the open studios promo page
  get information about the upcoming open studios
  so they can plan their virtual visit

Background:
  Given there is a scheduled Open Studios event
  And there are open studios artists with art in the system
  And there is open studios cms content in the system


Scenario:  Visiting the open studios promo page
  When I visit the home page
  When I click on the current open studios link
  Then I see the open studios promo page

@javascript
Scenario:  Visiting the open studios promo page as an editor
  When I visit the home page
  When I login as an editor
  When I visit the home page
  And I wait until the page is done loading infinite scroll
  And I click on the current open studios link
  Then I see the open studios promo page

  When I hover over a cms section
  And I click on "edit me"

  When I go to the new tab
  And I fill in the form with:
  | Article     |
  | new info about open studios  |
  And I click "Save"
  And I am on the show page for the new cms
  Then I see "new info about open studios" on the page

  When I visit the home page
  And I click on the current open studios link
  Then I see "new info about open studios" on the page

Scenario:  Visiting the open studios promo page on a phone
  When I visit the home page
  When I'm on my smart phone
  And I visit the about page
  And I click on the current open studios link
  Then I see the open studios cms content
