class AddUniqIndexOnEmails < ActiveRecord::Migration
  def self.up
    add_index :emails, :email, :unique => true
  end

  def self.down
    remove_index :emails, :email
  end
end
