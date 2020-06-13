# frozen_string_literal: true

class MoveUserIdToOwnerIdOnFavorites < ActiveRecord::Migration[6.0]
  def change
    rename_column :favorites, :user_id, :owner_id
  end
end
