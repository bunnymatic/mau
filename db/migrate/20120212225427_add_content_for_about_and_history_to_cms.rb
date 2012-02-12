# -*- coding: utf-8 -*-
ABOUT =<<EOM
#### What is Mission Artists United?

With the highest concentration of working artists in the city, the Mission is a vibrant community. Not only are we home to some of the most exciting emerging and established artists working in all media; the Mission also offers the art-lover great restaurants and cafes, a vibrant nightlife and some of the city's best shopping right in the center of San Francisco!

MISSION ARTISTS UNITED is working with city government and local businesses to find ways of coordinating marketing efforts, connecting artists, and working to establish the Mission as THE destination point for viewing and buying art. 

If you are an artist working in the Mission, then you are already part of MISSION ARTISTS UNITED! 

Join us by [signing up](/signup) and posting your portfolio or linking your blog.  Help us show the city our richness and diversity.  Help us to take our place at the center of artistic life in San Francisco!

Where is the Mission?  The Mission District is the area between Dolores and Potrero, Division and Cesar Chavez in San Francisco, CA. 

Want more?  See the [History of Mission Artists United](/history)

EOM

HISTORY =<<EOM
#### History of Mission Artists United

On March 6, 2009, several representatives from five multi-studio buildings in the Mission met for the first time.  All working artists, they met to discuss how to best market their impending Spring Open Studios.  They also wondered whether it was possible for artists who had not known each other, from different studio buildings to come together and do anything.  In the next six weeks until their Open Studios, they grew to represent seven studio buildings, they were amazed to find they worked very well together and their vision grew from marketing a single event to re-imagining the role the Mission District plays in the artistic life of the city!  What started as an experiment among a few artists has now become MISSION ARTISTS UNITED – representing all of the working artists of the Mission District (Division to Cesar Chavez, Potrero to Dolores) and promoting the Mission as the premier arts destination of San Francisco.

If you are an artist working in the Mission, then you are already part of MISSION ARTISTS UNITED! 

Join us by [signing up](/signup) and posting your portfolio or linking your blog.  Help us show the city our richness and diversity.  Help us to take our place at the center of artistic life in San Francisco!

EOM

class AddContentForAboutAndHistoryToCms < ActiveRecord::Migration
  def self.up
    page = 'main'
    section = 'about'
    doc = CmsDocument.find_by_page_and_section(page, section)
    if !doc || doc.nil?
      CmsDocument.create!( :page => page, :section => section, :article => ABOUT)
    end
    section = 'history'
    doc = CmsDocument.find_by_page_and_section(page, section)
    if !doc || doc.nil?
      CmsDocument.create!( :page => page, :section => section, :article => HISTORY)
    end

  end

  def self.down
  end
end
