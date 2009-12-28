class AddUrlToFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :url, :string, :null => :no
  end

  def self.down
    remove_column :feedbacks, :url
  end
end
