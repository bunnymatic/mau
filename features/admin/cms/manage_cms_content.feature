@javascript
Feature: Admin CMS Content
  As an admin
  I can manage the pieces of CMS content that we have on the site
  So that I can make sure the site makes sense

Background:
  Given an "admin" account has been created
  And I login
  And I click on "cms" in the admin menu

Scenario: Showing existing content
  Then I see the cms content page

Scenario: Adding CMS Content
  When I click "Add CMS Content"
  And I fill in the form with:
  | Page   | Section   | Article     |
  | mypage | mysection | # my header |
  And I click "Save"
  Then I see "my header" in the "#processed_markdown h1"
  And I click "Back"
  Then I see "mypage" in the "table.js-data-tables"
  And I see "mysection" in the "table.js-data-tables"
  When I click "Delete"
  Then I see a flash notice "CmsDocument was removed"
  And I see no cms content in the list

Scenario: Adding CMS Content for the about page
  When I click "Add CMS Content"
  And I fill in the form with:
  | Page | Section | Article                           |
  | main | about   | # we rule the school\n\n*why not* |
  And I click "preview"
  Then I see "we rule the school" in the "#processed_markdown h1"
  And I click "edit"
  When I click "Save"
  And I visit the about page
  Then I see "we rule the school" in the ".markdown h1"
