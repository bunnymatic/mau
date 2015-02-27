Feature: As a user I can sign up

Background:
  Given I know how to fill out a recaptcha
  Given there is a studio named "1990"
  Given I visit the signup page

Scenario: sign up as a fan
  When I click "Sign up"
  Then I see an error in the form "should look like an email"
  And I see an error in the form "can't be blank"
  When I choose "Mission Art Fan" from "I am a"
  And I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name |
  | billybob | billybob@email.com | password | password              | billy      | bob       |
  And I click "Sign up"
  Then I see that "billybob" is a new fan

Scenario: sign up as a artist
  When I click "Sign up"
  Then I see an error in the form "should look like an email"
  And I see an error in the form "can't be blank"
  And see an error in the form "is too short"
  When I choose "Mission Artist" from "I am a"
  And I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name |
  | billybob | billybob@email.com | password | password              | billy      | bob       |
  And I click on "Sign up" in the "form"
  Then I see that "billybob" is a new pending artist

Scenario: sign up as a artist with a studio
  When I choose "Mission Artist" from "I am a"
  And I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name | Studio |
  | billybob | billybob@email.com | password | password              | billy      | bob       |   1990 |
  And I click "Sign up"
  Then I see that "billybob" is a new pending artist
  And I see that the studio "1990" has an artist called "billybob"

# @javascript
# Scenario: choose the artistsign up as a artist
#   And I click "Sign up"
#   Then I see an error in the form "should look like an email"
#   Then I see an error in the form "can't be blank"
#   Then I see an error in the form "is too short"
#   When I choose "Mission Artist" from "I am a"
#   When I fill in the "#signup_form" form with:
#   | Username | Email              | Password | Password confirmation | First Name | Last Name |
#   | billybob | billybob@email.com | password | password              | billy      | bob       |
#   And I click on "Sign up" in the "form"
#   Then I see that "billybob" is a new pending artist
