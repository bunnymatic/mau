class ChangeDefaultsForUserEmailAttrs < ActiveRecord::Migration
  def self.up
    change_column :users, :email_attrs, :string, :default => '{"fromartist": true, "favorites": true, "fromall": true}'
  end

  def self.down
    change_column :users, :email_attrs, :string, :default => '{"fromartist": true, "favorites": true, "fromall": true}'  end
end
