class AddCrossStreetToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :cross_street, :string
    add_column :studios, :phone, :string
  end

  def self.down
    remove_column :studios, :phone
    remove_column :studios, :cross_street
  end
end
