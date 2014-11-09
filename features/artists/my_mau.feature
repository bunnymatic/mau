Feature:
  As an artist
  I can see my page with my art and a menu of useful actions

Background:
  Given I login as an artist
  And there are future open studios events

Scenario:
  When I visit my home page
  Then I see my art
  And I see my big thumbs on the left
  And I see the artist's menu

@javascript
Scenario:
  When I visit my profile edit page
  Then I see my profile edit form

  When I click on "Personal Info"
  And I update my personal information with:
  | artist_firstname | artist_lastname |
  | joe              | blow            |
  And I click on "Save Changes"

  Then I see my profile edit form
  And I close the notice
  When I click on "Personal Info"
  Then I see my updated personal information as:
  | artist_firstname | artist_lastname |
  | joe              | blow            |

  When I click on the first "Open Studios" link
  And I click on "yep"
  Then I see a flash notice "more the merrier"
  And I close the notice
  And I save a screenshot
  And I see that I've successfully signed up for Open Studios

  And I click on "nope"
  Then I see a flash notice "So sorry"
  And I close the notice
  Then I see that I've successfully unsigned up for Open Studios

  And I click on "yep"
  Then I see a flash notice "more the merrier"
  And I close the notice

  Then I click on "Links"
  And I update my personal information with:
  | Flickr            |
  | www.flickr.com/me |
  And I click on "Save"
  Then I see that I've successfully signed up for Open Studios
  Then I click on "Links"
  And I see my updated personal information as:
  | artist_artist_info_flickr  |
  | www.flickr.com/me         |
