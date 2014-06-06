Feature: Manage Media

As an administrator, I can manage the media that artists can use for art pieces

Background:
  Given an "admin" account has been created
  And I login
  And I click on "media" in the admin menu

Scenario: Showing the media as an admin
  Then I see the admin media list


Scenario: Editing a media
  When I click on "Edit"
  And I fill in "blah" for "name"
  Then I see the admin media list
  And I see the "blah" as a medium



