Feature: Managing system internal email lists
  As an admin user, I can view the system's internal email lists.
  And I can add and delete emails to the different lists

Background:
  Given an "admin" account has been created
  And I login
  And I click on "admin email lists" in the admin menu

Scenario: 
  Then I can see the "Feedbacks" email list
  And I can see the "Events" email list
  And I can see the "Admin" email list

Scenario: Adding an email
  When I click to add an email to the "Events" list
  And I fill in the form with 
    | email               | name     |
    | "email@example.com" | joe blow | 
  And I click "Add"
  Then I see that "joe blow <email@example.com>" is on the "Events" email list
  When I click to add an email to the "Feedbacks" list
  And I fill in the form with 
    | email               |
    | "email@example.com" |
  And I click "Add"
  Then I see that "joe blow <email@example.com>" is on the "Feedbacks" email list

  
