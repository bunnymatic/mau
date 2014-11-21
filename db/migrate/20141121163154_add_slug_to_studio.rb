class AddSlugToStudio < ActiveRecord::Migration
  def change
    add_column :studios, :slug, :string
    add_index :studios, :slug, :unique => true
  end
end
