Feature: MAU Fans
  As an fan
  I can see my page with my art and a menu of useful actions

Background:
  Given I login as a fan

@javascript
Scenario:
  When I visit my user profile edit page
  Then I see my fan profile edit form

  When I click on "Personal Info"
  And I update my personal information with:
  | user_firstname | user_lastname |
  | joe            | blow          |
  And I click on "Save Changes"

  Then I see my fan profile edit form
  And I close the notice
  When I click on "Personal Info"
  Then I see my updated personal information as:
  | user_firstname | user_lastname |
  | joe            | blow          |

  When I click on "Profile Picture"
  And I submit a new profile picture
  And I click "Save Changes"
  And I click on "Profile Picture"
  Then I see that I have a new profile picture
