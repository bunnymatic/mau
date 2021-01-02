Feature: Visitors can submit feedback and ask for help


@javascript
Scenario:  Visitors can submit feedback
  When I visit the home page
  And I click on "feedback"
  And I fill in the feedback form
  Then I see that my feedback was submitted
  And the system knows that my feedback was submitted

@javascript
Scenario: Visitors can submit inquiries
  When I visit the home page
  And I click on "contact"
  And I click on "email"
  And I fill in the inquiry form
  Then I see that my inquiry was submitted
  And the system knows that my inquiry was submitted
