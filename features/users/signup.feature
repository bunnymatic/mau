Feature: As a user I can sign up

Background:
  Given I know how to fill out a recaptcha
  Given there is a studio named "1990"
  Given I visit the signup page

  # Scenario: sign up as a fan
  #   When I fill in the form with:
  #   And I click "Sign up"
  #   Then I see errors
  #   When I fill in the fan form with:
  #   And I click "Sign up"
  #   Then I see that I am a new fan

@javascript
Scenario: sign up as a artist
  And I take a screenshot
  And I click "Sign Up Now"
  Then I see an error message "should look like an email"
  Then I see an error message "can't be blank"
  Then I see an error message "is too short"
  Then I close the flash
  When I choose "Mission Artist" from "I am a"
  When I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name |
  | billybob | billybob@email.com | password | password              | billy      | bob       |
  And I click "sign up"
  Then I see that "billybob" is a new pending artist

@javascript
Scenario: sign up as a artist with a studio
  When I choose "Mission Artist" from "I am a"
  When I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name | Studio |
  | billybob | billybob@email.com | password | password              | billy      | bob       |   1990 |
  And I click "sign up"
  And I take a screenshot
  Then I see that "billybob" is a new pending artist
