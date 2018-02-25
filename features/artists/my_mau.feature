@javascript
Feature:
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
  | artist_firstname | artist_lastname |
  | joe              | 蕭秋芬          |
  And I click on "Save Changes"

  Then I see my profile edit form
  And I close the notice
  When I click on "Personal Info"
  Then I see my updated personal information as:
  | artist_firstname | artist_lastname |
  | joe              | 蕭秋芬          |

  And I click on "Personal Info"

  And I update my personal information with:
  | artist_firstname |
  | mr joe           |
  And I click on "Save Changes"
  Then I click on "Personal Info"
  And I see my updated personal information as:
  | artist_firstname  |
  | mr joe            |
  And I see that I've successfully signed up for Open Studios

  When I click on "Profile Picture"
  And I submit a new profile picture
  And I click "Save Changes"
  And I click on "Profile Picture"
  Then I see that I have a new profile picture

Scenario: I can update my os status
  When I visit my artist profile edit page
  Then I see my profile edit form

  And I click on "Personal Info"

  When I click on the current open studios edit section
  And I check nope for doing open studios
  Then I see a flash notice including "So sorry"
  And I close the notice
  Then I see that I've successfully unsigned up for Open Studios

  And I check yep for doing open studios
  Then I see a flash notice including  "Look for an email"
  And I see a flash notice including "Thanks for participating"

  And I close the notice
  And I see that I've successfully signed up for Open Studios
