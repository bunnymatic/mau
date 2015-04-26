Feature:
  Visitors can submit feedback


@javascript
Scenario:  Visitors can submit feedback
  When I visit the home page
  And I click on "feedback"
  And I fill in the feedback form
  Then I see that my feedback was submitted
  And the system knows that my feedback was submitted
