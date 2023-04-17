@javascript
Feature: Managing system internal email lists
  As an admin user, I can view the system's internal email lists.
  And I can add and delete emails to the different lists

Background:
  Given an "admin" account has been created
  And the email lists have been created with emails
  And I login
  And I visit the "admin email_lists" page

Scenario:
  Then I can see the "Feedback" email list
  And I can see the "Admins" email list

Scenario: Adding an email
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | email             | name      |
  | add_email@example.com  | joe blow |
  And I click "Add" in the "Feedback" email form
  Then I see that "joe blow <add_email@example.com>" is on the "Feedback" email list


Scenario: Removing an email
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | email               | name      |
  | new_email@example.com   | joe blow |
  And I click "Add" in the "Feedback" email form
  Then I see that "joe blow <new_email@example.com>" is on the "Feedback" email list
  And I click to remove "new_email@example.com" from the "Feedback" list
  Then I see that "joe blow <new_email@example.com>" is not on the "Feedback" email list

@javascript
Scenario: Adding the same email twice to one list
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | email               | name       |
  | joe_blows_email@example.com   | joe blow |
  And I click "Add" in the "Feedback" email form
  Then I see that "joe blow <joe_blows_email@example.com>" is on the "Feedback" email list
  And I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | email               |
  | joe_blows_email@example.com   |
  And I click "Add" in the "Feedback" email form
  Then I see an inline form error "Email list has already been taken"
