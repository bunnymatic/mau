@javascript
Feature: As a active artist I can edit my information

Background:
  Given I am signed in as an artist
  And I click on the first "My Account" link

Scenario: I can edit my personal information
  When I click on "Personal Info"
  And I change "First Name" to "Soup"
  And I click on "Save Changes"
  Then my "First Name" is "Soup" in the "Personal Info" section of the form

  And I change "Display Name" to "Soup"
  And I click on "Save Changes"
  Then my "Display Name" is "Soup" in the "Personal Info" section of the form

Scenario: I can edit my address and studio affiliation
  When I click on "Address/Studio Info"
  And I change "Studio #" to "6600"
  And I click on "Save Changes"
  Then my "Studio #" is "6600" in the "Address/Studio Info" section of the form

Scenario: I can edit my profile picture
  When I click on "Profile Picture"
  And I add a photo to upload
  And I click on "Upload"
  When I click on "Profile Picture"
  Then I see my photo in my profile

Scenario: I can edit my links
  When I click on "Links"
  And I change "Website" to "http://my.website.com"
  And I change "Instagram" to "http://instagram.com/my_instagram"
  And I click on the first "Save Changes"
  Then my "Website" is "http://my.website.com" in the "Links" section of the form
  And my "Instagram" is "http://instagram.com/my_instagram" in the "Links" section of the form

Scenario: I can edit my bio
  When I click on "Bio"
  And I change "artist_artist_info_attributes_bio" to "this Is my new bio"
  And I click on "Save Changes"
  Then my "artist_artist_info_attributes_bio" is "this Is my new bio" in the "Bio" section of the form

Scenario: I can edit my password
  When I click on "Password"
  And I change "Current Password" to "8characters"
  And I change "artist_password" to "blahdeblah"
  And I change "Confirm New Password" to "blahdeblah"
  And I click on "Save Changes"
  Then I see a flash notice "Your password has been updated"

  When I sign out
  And I click on "sign in"
  And I sign in with password "blahdeblah"
  Then I see that I'm signed in

Scenario: I cannot edit my password if i can't remember my current password
  When I click on "Password"
  And I change "Current Password" to "something"
  And I change "artist_password" to "blahdeblah"
  And I change "Confirm New Password" to "blahdeblah"
  And I click on "Save Changes"
  Then I see a flash error including "Your old password was incorrect"
  And I close the flash
  And I sign out
  And I click on "sign in"
  # same old password works
  And I sign in with password "8characters"
  And I close the flash
  Then I see that I'm signed in

Scenario: I cannot edit my password if the confirmation doesn't match
  When I click on "Password"
  And I change "Current Password" to "8characters"
  And I change "artist_password" to "blahdeblah"
  And I change "Confirm New Password" to "blahblahxx"
  And I click on "Save Changes"
  Then I see a flash error including "Password confirmation doesn't match"
