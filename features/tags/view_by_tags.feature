Feature: Show artists and art by tags
  As a user, 
  I can see a list of MAU artists by tag
  I can also see a list of art pieces by tag
  And I can paginate through those pages easily
  So I can see how awesome Mission Artists are and I will be motivated to come to Open Studios and buy stuff
  
Background:
  Given the cache is clear
  Given there are artists with art in the system
  And there are tags on the art
  And I visit the "art piece tags" page

Scenario: Visit artists by tag
  Then I see a list of artists who have art in the most popular tag
  And I click on the first "next" button
  Then I see more artists who have art in the most popular tag
