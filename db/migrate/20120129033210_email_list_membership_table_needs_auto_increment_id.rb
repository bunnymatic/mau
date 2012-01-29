class EmailListMembershipTableNeedsAutoIncrementId < ActiveRecord::Migration
  def self.up
    remove_column :email_list_memberships, :id
    add_column :email_list_memberships, :id, :primary_key
  end

  def self.down
    remove_column :email_list_memberships, :id
    add_column :email_list_memberships, :id, :integer
  end
end
