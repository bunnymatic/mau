class JoinAllOpenStudiosColumns < ActiveRecord::Migration
  def self.up
    ArtistInfo.all.each do |a|
      a.os_participation = {
        '201010' => a.osoct2010,
        '201004' => a.os2010
      }
      a.save
    end
    remove_column :artist_infos, :os2010
    remove_column :artist_infos, :osoct2010
  end

  def self.down
    add_column :artist_infos, :os2010, :boolean, :default => false
    add_column :artist_infos, :osoct2010, :boolean, :default => false
    ArtistInfo.all.each do |a|
      a.send('os2010=', a.os_participation['201004'])
      a.send('osoct2010=', a.os_participation['201010'])
      a.save
    end
  end
end
