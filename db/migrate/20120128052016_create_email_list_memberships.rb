class CreateEmailListMemberships < ActiveRecord::Migration
  def self.up
    create_table :email_list_memberships, :id => false do |t|
      t.integer :email_id
      t.integer :email_list_id
    end
  end

  def self.down
    drop_table :email_list_memberships
  end
end
