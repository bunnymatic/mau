class CreateScammers < ActiveRecord::Migration
  def self.up
    create_table :scammers do |t|
      t.text :email
      t.text :name
      t.integer :faso_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scammers
  end
end
