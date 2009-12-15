class ActivateExistingArtists < ActiveRecord::Migration
  def self.up
    execute "update artists set state='active' where state='passive'"
  end

  def self.down
  end
end
