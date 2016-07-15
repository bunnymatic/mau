class AddIndecesOnEmailListMemberships < ActiveRecord::Migration
  def change
    add_index :email_list_memberships, :email_list_id
    add_index :email_list_memberships, :email_id
  end
end
