@javascript
Feature: Viewing the os catalog
  As an admin user, I can navigate to the catalog

Background:
  Given an "admin" account has been created
  And I login

Scenario: I can see an empty catalog
  When I visit "/catalog"
  Then I see "Artists by Studio" on the page

Scenario: I can see an empty social catalog
  When I visit "/catalog/social"
  Then I see "Nothing to show here" on the page

Scenario: I can see a full catalog
  When there are open studios artists with art in the system
  When I visit "/catalog"
  Then I see "Artists by Studio" on the page

Scenario: I can see a full social catalog
  When there are open studios artists with art in the system
  When I visit "/catalog/social"
  Then I see the open studios artists' login on the page
