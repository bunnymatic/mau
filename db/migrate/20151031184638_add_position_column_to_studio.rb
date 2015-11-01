class AddPositionColumnToStudio < ActiveRecord::Migration
  def change
    add_column :studios, :position, :integer, default: 1000
  end
end
