Feature: As a user I can sign up

Background:
  Given there is a studio named "1990"
  Given I visit the signup page

# Scenario: sign up as a fan
#   When I fill in the form with:
#   And I click "Sign up"
#   Then I see errors
#   When I fill in the fan form with:
#   And I click "Sign up"
#   Then I see that I am a new fan

Scenario: sign up as a artist
  And I click "Sign up"
  Then I see an error message "should look like an email"
  Then I see an error message "can't be blank"
  Then I see an error message "is too short"
  When I fill in the form with:
  | Username | E-mail             | Password | Password Confirmation | Firstname | Lastname |
  | billybob | billybob@email.com | password | password              | billy     | bob      |
  And I click "Sign up"
  Then I see that "billybob" is a new pending artist

Scenario: sign up as a artist with a studio
  When I fill in the form with:
  | Username | E-mail             | Password | Password Confirmation | Firstname | Lastname | Group Studio |
  | billybob | billybob@email.com | password | password              | billy     | bob      | 1990   |
  And I click "Sign up"
  Then I see that "billybob" is a new pending artist
