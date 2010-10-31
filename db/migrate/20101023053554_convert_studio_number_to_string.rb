class ConvertStudioNumberToString < ActiveRecord::Migration
  def self.up
    change_column :artists, :studionumber, :string
  end

  def self.down
    change_column :artists, :studionumber, :integer
  end
end
