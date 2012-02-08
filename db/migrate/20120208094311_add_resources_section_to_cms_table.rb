class AddResourcesSectionToCmsTable < ActiveRecord::Migration

  ARTICLE = <<EOM
## Artist Resources  
### Open Studios

Spring Open Studios is going to be here before you know it.  [Get more info here](/main/openstudios)

We hold two large Open Studios events each year where artists all over the
Mission open their doors to the public for a whole weekend.  Art lovers from
all over come to see the creativity and innovation of their favorite local
artists in our favorite San Francisco neighborhood.

##### Spring Open Studios will be April 14,15 2012.

##### Fall Open Studios will be held in October 2012.

To keep up on all the latest MAU news, you can join our <a href="/contact">email list.</a>

[Spring Open Studios](http://www.springopenstudios.com) is an event that takes place over 3 weekends in 3 neighborhoods.  [Fall Open Studios](http://artspan.org) takes place over 5 weekends and covers the whole city of San Francisco.

### Artists Resources

##### Sign up for Flax Live Painting!

Howard Flax is inviting all MAU artists to join in and participate in a live painting program he's recently started in the store.  It's an opportunity to give you, the artist, more exposure, and to help promote Mission Artists United.  The store, in return, get's new energy and excitement in the store.  If you are interested, please read <a href="#" class="read-more">click here to read more</a>.  To sign up, <a href="javascript:MAU.mailer('leslie','flaxart.com','Sign me up for Live Painting!');">email Leslie Flax</a>.  


##### Open Studios Guide

[Tips for the Artist](http://trishtunney.blogspot.com/2010/03/fun-and-successful-open-studios.html) from Trish Tunney.

##### MAU Gear!

* [Art is the Mission shirts and gear](http://www.cafepress.com/ArtIsTheMission)
* [Mission Artists United Logo gear](http://www.cafepress.com/MissionArtists)
EOM

  def self.up
    page = 'main'
    section = 'artist_resources'
    doc = CmsDocument.find_by_page_and_section(page, section)
    if !doc || doc.nil?
      CmsDocument.create!( :page => page, :section => section, :article => ARTICLE)
    end
  end

  def self.down
  end
end
