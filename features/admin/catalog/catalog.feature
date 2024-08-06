@javascript
Feature: Viewing the os catalog
  As an admin user, I can navigate to the catalog

Background:
  Given an "admin" account has been created
  And there are open studios artists with art in the system
  And I login

Scenario:login with good info
  When I visit "/catalog"
  Then I see "Artists by Studio" on the page
