ARTICLE =<<EOM

## Not Yet A MAU Member?

You can get an artist membership or a fan membership.

The artist membership allows you to upload your portfolio, take part in our Mission Open Studios events,  get listed in our Open Studios online catalog.  Use it to get your work out there!  You just need to be an artist working in the Mission district of San Francisco.

If you are a fan of MAU, you can use the fan account to save your favorite artists, create a custom catalog including only the artists you want to see and more.

Joining is free and easy.
EOM

class AddSignupTextToCms < ActiveRecord::Migration
  def self.up
    page = 'signup'
    section = 'signup'
    doc = CmsDocument.find_by_page_and_section(page, section)
    if !doc || doc.nil?
      CmsDocument.create!( :page => page, :section => section, :article => ARTICLE)
    end
  end

  def self.down
  end
end

