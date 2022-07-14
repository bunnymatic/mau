class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.string :message, null: false
      t.datetime :activated_at

      t.timestamps
    end
  end
end
