Feature:
  As an artist
  I can see my page with my art and a menu of useful actions

Background:
  Given I login as an artist

Scenario:
  When I visit my home page
  Then I see my art
  And I see my big thumbs on the left
  And I see the artist's menu

@javascript
Scenario:
  When I visit my profile edit page
  Then I see my profile edit form

  When I click on the first "Personal Info" link
  And I update my personal information with:
  | artist_firstname | artist_lastname |
  | joe              | blow            |
  Then I see my profile edit form
  And I close the notice
  When I click on the first "Personal Info" link
  Then I see my updated personal information as:
  | artist_firstname | artist_lastname |
  | joe              | blow            |

