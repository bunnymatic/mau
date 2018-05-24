@javascript
Feature: Admin view of tags
  I can check out all the tags and see who's using what
  I can clean out unused tags
  So I can keep the system clean and well oiled

Background:
  Given an "admin" account has been created
  And there are artists with art in the system
  And there are tags on the art
  And I login

Scenario: Viewing and cleaning out tags
  When I click on "tags" in the admin menu
  Then I see the "admin art piece tags" page
  When I destroy the first tag
  Then I see the "admin art piece tags" page
  And I don't see the first tag anymore
