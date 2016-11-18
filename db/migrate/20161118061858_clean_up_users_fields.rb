class CleanUpUsersFields < ActiveRecord::Migration
  def up
    change_table :artist_infos do |t|
      t.remove :news
      t.remove :facebook
      t.remove :twitter
      t.remove :blog
      t.remove :myspace
      t.remove :flickr
      t.remove :pinterest
      t.remove :instagram
    end
  end

  def down
    change_table :artist_infos do |t|
      t.column :news, :text
      t.column :facebook, :string
      t.column :twitter, :string
      t.column :blog, :string
      t.column :myspace, :string
      t.column :flickr, :string
      t.column :pinterest, :string
      t.column :instagram, :string
    end
  end

end
