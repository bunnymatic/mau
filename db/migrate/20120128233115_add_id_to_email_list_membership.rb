class AddIdToEmailListMembership < ActiveRecord::Migration
  def self.up
    add_column :email_list_memberships, :id, :integer
  end

  def self.down
    remove_column :email_list_memberships, :id
  end
end
