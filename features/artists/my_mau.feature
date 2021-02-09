@javascript
Feature: Artists Account
  As an artist
  I can see my page with my art and a menu of useful actions

Background:
  Given there are future open studios events
  And I login as an artist
  And that artist is doing open studios

Scenario: I can edit my profile
  When I visit my artist profile edit page
  Then I see my profile edit form

  When I click on "Personal Info"
  And I update my personal information with:
  | artist_firstname | artist_lastname | artist_phone            |
  | joe              | 蕭秋芬           | 1 (415) 555 1212 |
  And I click on "Save Changes"

  Then I see a flash notice including "has been updated"
  And I see my profile edit form
  And I close the notice

  When I click on "Personal Info"
  Then I see my updated personal information as:
  | artist_firstname | artist_lastname | artist_phone           |
  | joe              | 蕭秋芬           | 415.555.1212        |

  When I update my personal information with:
  | artist_firstname |
  | mr joe           |
  And I click on "Save Changes"
  Then I see a flash notice including "has been updated"
  And I see my profile edit form
  And I close the notice
  And I click on "Personal Info"
  Then I see my updated personal information as:
  | artist_firstname  |
  | mr joe            |

  When I open the "Profile Picture" profile section
  And I submit a new profile picture
  And I click "Save Changes"
  And I see a flash notice including "has been updated"

  When I open the "Profile Picture" profile section
  Then I see that I have a new profile picture

Scenario: I can update my os status
  When I visit my profile edit page
  Then I see my profile edit form

  And I click on "Personal Info"

  When I click on the current open studios edit section
  And I click on "Update my registration status"

  Then I see the registration dialog
  And I click on "No" in the ".ngdialog"
  Then I see the registration message

  When I click on "Yes - Register Me"
  And I see the registration dialog
  And I click on "Yes" in the ".ngdialog"
  Then I see the update my registration message

Scenario: I can see when I make a mistake
  When I visit my artist profile edit page
  Then I see my profile edit form

  When I click on "Personal Info"
  And I update my personal information with:
  | artist_email   | artist_phone |
  |                |  123 44      |
  And I click on "Save Changes"

  Then I see a flash error including "We had trouble updating your profile."
  Then I see an error in the form "can't be blank"
  Then I see an error in the form "10 or 11 digits"

  When I close the flash
  And I update my personal information with:
  | artist_email               | artist_phone   |
  | leodvinci@example.com     | 1 234 444 5555 |
  And I click on "Save Changes"

  When I click on "Personal Info"
  And I see my updated personal information as:
  | artist_email               | artist_phone   |
  | leodvinci@example.com     | 234.444.5555     |

  Then I see a flash notice including "has been updated"
