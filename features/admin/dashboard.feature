Feature: Viewing the admin dashboard
  As an admin user, I can see the admin dashboard

Background:
  Given an "admin" account has been created
  And I login

Scenario:login with good info
  When I click on "dashboard" in the admin menu
  Then I see the admin dashboard
