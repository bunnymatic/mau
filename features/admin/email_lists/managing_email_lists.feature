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
  And I can see the "Admin" email list

@javascript
Scenario: Adding an email
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | Email             | Name     |
  | email@example.com | joe blow |
  And I click "add" in the "Feedback" email form
  Then I see that "joe blow <email@example.com>" is on the "Feedback" email list

@javascript
Scenario: Removing an email
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | Email               | Name     |
  | email@example.com   | joe blow |
  And I click "add" in the "Feedback" email form
  Then I see that "joe blow <email@example.com>" is on the "Feedback" email list
  And I click to remove "email@example.com" from the "Feedback" list
  Then I see that "joe blow <email@example.com>" is not on the "Feedback" email list

@javascript
Scenario: Adding an invalid email
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | Email               | Name     |
  | "email@"            | joe blow |
  And I click "add" in the "Feedback" email form
  Then I see an error message "should look like an email"

@javascript
Scenario: Adding the same email twice to one list
  When I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | Email               | Name     |
  | email@example.com   | joe blow |
  And I click "add" in the "Feedback" email form
  Then I see that "joe blow <email@example.com>" is on the "Feedback" email list
  And I click to add an email to the "Feedback" list
  And I fill in the "Feedback" email form with:
  | Email               |
  | email@example.com   |
  And I click "add" in the "Feedback" email form
  Then I see an error message "Email list has already been taken"
