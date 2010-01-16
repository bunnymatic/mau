class AddEmailPermsToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :email_attrs, :string, :default => '{"fromartist": true, "mauadmin": true, "maunews": true, "fromall": false}'
  end

  def self.down
    remove_column :artists, :email_attrs
  end
end
