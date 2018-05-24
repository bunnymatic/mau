@javascript
Feature: Viewing the admin dashboard
  As an admin user, I can see the admin dashboard

Background:
  Given an "admin" account has been created
  And I login

Scenario:login with good info
  When I click on "dashboard" in the admin menu
  Then I see the admin dashboard
  And I see the "totals" admin stats
  And I see the "yesterday" admin stats
  And I see the "last week" admin stats
  And I see the "last 30 days" admin stats
  And I see the "open studios" admin stats
  And I see the "social links" admin stats
