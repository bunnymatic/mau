class CreateCmsDocument < ActiveRecord::Migration
  def self.up
    create_table :cms_documents do |t|
      t.string :page
      t.string :section
      t.text :article
      t.timestamps
    end
  end

  def self.down
    drop_table :cms_documents
  end
end
