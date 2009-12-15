class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.string :subject
      t.string :email
      t.string :login
      t.string :page
      t.text   :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :feedbacks
  end
end
