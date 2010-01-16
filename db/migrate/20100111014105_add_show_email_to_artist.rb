class AddShowEmailToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :showemail, :boolean, :default => 1
  end

  def self.down
    remove_column :artists, :showemail
  end
end
