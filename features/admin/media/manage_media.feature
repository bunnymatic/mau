@javascript
Feature: Manage Media

As an administrator, I can manage the media that artists can use for art pieces

Background:
  Given an "admin" account has been created
  And I login
  And I click on "media" in the admin menu

Scenario: Showing the media as an admin
  Then I see the admin media list

Scenario: Editing a media
  When I click on the first "Edit" button
  And I fill in "medium_name" with "blah de blah"
  And I click "Update"
  Then I see the admin media list
  And I see the "blah" as a medium
