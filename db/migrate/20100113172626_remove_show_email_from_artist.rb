class RemoveShowEmailFromArtist < ActiveRecord::Migration
  def self.up
    remove_column :artists, :showemail
  end

  def self.down
    add_column :artists, :showemail, :boolean, :default => 1
  end
end
