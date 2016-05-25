class AddIndexOnFavorites < ActiveRecord::Migration
  def change
    add_index :favorites, [:favoritable_type, :favoritable_id, :user_id], name: :index_favorites_uniq_on_user_and_favorite, unique: true
  end
end
