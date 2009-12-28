class AddSkillsetToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :skillsets, :string
  end

  def self.down
    remove_column :feedbacks, :skillsets
  end
end
