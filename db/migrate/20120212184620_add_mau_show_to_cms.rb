# -*- coding: utf-8 -*-
ARTICLE =<<EOM

### Mission Artists United, the Spring Directory Show

Workspace!

Our team of awesome Jurors will review your entry and decide who gets in

 * Juror1 of [Juror one website](http://www.example.com)
 * Juror 2 of [Juror Two Website](http://www.example.com)

The entry fee is only $10 and goes towards promoting Spring Open
Studios. Don’t miss this amazing opportunity!

### Entry Instructions

Entries must be 20&quot; x 20&quot; or smaller (for 2d) and 16&quot; High x 12&quot; Wide x 12&quot; Deep (for 3d - Some shelves only accommodate 6'' Depth, so small work is OK.).

We're using EntryThingy to manage submissions.  To get there you'll need to:

- [Login](http://missionartistsunited.org/login) (if you're not already logged in to MAU)
- Set your MAU status to "I'm participating in Open Studios".  If you haven't done that...
     - Click on "edit my page (above under my mau)"
     - Click on the Open Studios section
     - Click on the "Yep!" button.
- When that's all set, click the button below and start your entry!

[Submit your work!](/wizards/mau042012_entrythingy)
EOM


class AddMauShowToCms < ActiveRecord::Migration


  def self.up
    page = 'show_submissions'
    section = 'spring2012'
    doc = CmsDocument.find_by_page_and_section(page, section)
    if !doc || doc.nil?
      CmsDocument.create!( :page => page, :section => section, :article => ARTICLE)
    end
  end

  def self.down
  end

end

