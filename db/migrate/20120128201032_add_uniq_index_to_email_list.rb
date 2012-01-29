class AddUniqIndexToEmailList < ActiveRecord::Migration
  def self.up
    add_index :email_lists, :type, :unique => true
  end

  def self.down
    remove_index :email_lists, :type
  end
end
