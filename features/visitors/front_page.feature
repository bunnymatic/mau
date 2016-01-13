Feature:

  Visitors to the home page see a sampling of artists, the new art that's been added to the system
  and a list of art related feeds.

  They should also see a banner talking about open studios and a menu of options to dig into seeing more artists


Background:
  Given there are artists with art in the system
  And there are future open studios events

@javascript
Scenario:  Visiting the home page
  When I visit the home page
  Then I see some of the art that's in the system
  And the page meta name "description" includes "Mission Artists United is a website"
  And the page meta property "og:description" includes "Mission Artists United is a website"
  And the page meta name "keywords" includes "art is the mission"
  And the page meta name "keywords" includes "artists"
  And the page meta name "keywords" includes "san francisco"
      # it 'has the default description & keywords' do
      #   assert_select 'head meta[name=description]' do |desc|
      #     expect(desc.length).to eql 1
      #     expect(desc[0].attributes['content']).to match /^Mission Artists United is a website/
      #   end
      #   assert_select 'head meta[property=og:description]' do |desc|
      #     expect(desc.length).to eql 1
      #     expect(desc[0].attributes['content']).to match /^Mission Artists United is a website/
      #   end
      #   assert_select 'head meta[name=keywords]' do |keywords|
      #     expect(keywords.length).to eql 1
      #     expected = ["art is the mission", "art", "artists", "san francisco"]
      #     actual = keywords[0].attributes['content'].split(',').map(&:strip)
      #     expected.each do |ex|
      #       expect(actual).to include ex
      #     end
      #   end
      # end
