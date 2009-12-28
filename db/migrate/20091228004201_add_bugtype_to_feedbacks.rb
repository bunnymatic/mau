class AddBugtypeToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :bugtype, :string
  end

  def self.down
    remove_column :feedbacks, :bugtype
  end
end
