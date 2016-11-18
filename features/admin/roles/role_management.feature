@javascript
Feature: Manage Roles

As an administrator, I can manage users and their roles

Background:
  Given a "manager" account has been created
  Given a "editor" account has been created
  Given an "admin" account has been created
  And there are artists with art in the system
  And I login
  And I click on "roles" in the admin menu

Scenario: Showing the users and their roles
  Then I see the admin roles page

Scenario: Managing users in their roles
  When I click on the manage link for editors
  And I click on "add users to role"
  And I choose the last user in the user list
  And I click "add user"
  Then I expect to see the last user is now an editor

  When I remove a user from the editor list
  Then I expect to see that user is not an editor

Scenario: Adding a new role
  When I add a new role called "juror"
  Then I see there is a role called "juror"

  When I add a user to the "juror" role
  And I click on "roles" in the admin menu
  Then I see there is a role called "juror" with 1 user

  When I remove the role "juror"
  Then I see there is not a role called "juror"
