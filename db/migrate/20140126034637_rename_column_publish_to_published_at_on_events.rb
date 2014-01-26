class RenameColumnPublishToPublishedAtOnEvents < ActiveRecord::Migration
  def change
    rename_column :events, :publish, :published_at
  end
end
