class AddSubmitterToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :submitting_user_id, :integer
    add_column :events, :publish, :datetime
  end

  def self.down
    remove_column :events, :submitting_user_id
    remove_column :events, :publish
  end
end
