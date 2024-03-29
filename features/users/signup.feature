Feature: As a user I can sign up

Background:
  Given there is a studio named "1990"
  Given I visit the signup page

@javascript
Scenario: sign up as a artist
  Given mailchimp is handled
  When I click "Sign up"
  Then I see a flash error "secret word"
  And I see the secret word email link
  And I see an error in the form "can't be blank"
  And I see an error in the form "is too short"
  When I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name | secret_word      |
  | billybob | billybob@email.com | password | password              | billy      | bob       | eat-shit-hackers |
  And I click on "Sign up" in the "form"
  Then I see that "billybob" is a new active artist

@javascript
Scenario: sign up as a artist with a studio
  Given mailchimp is handled
  When I fill in the "#signup_form" form with:
  | Username | Email              | Password | Password confirmation | First Name | Last Name | Studio | secret_word      |
  | billybob | billybob@email.com | password | password              | billy      | bob       |   1990 | eat-shit-hackers |
  And I click "Sign up"

  Then I see that "billybob" is a new active artist
  And I see that the studio "1990" has an artist called "billybob"
