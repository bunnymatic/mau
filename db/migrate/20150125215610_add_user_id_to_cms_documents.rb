class AddUserIdToCmsDocuments < ActiveRecord::Migration
  def change
    add_column :cms_documents, :user_id, :integer
    add_index :cms_documents, :user_id
  end
end
