class RemoveAddressInfoFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :street, :city, :addr_state, :zip, :lat, :lng
  end

  def self.down
    cols = [[:street, :string],
            [:city, :string],
            [:addr_state, :string, {:limit => 4}],
            [:zip, :integer], 
            [:lng, :float],
            [:lat, :float]].each do |c|
      add_column :users, *c
    end
    execute('update users u join artist_infos ai on ai.artist_id = u.id set u.street=ai.street, u.city=ai.city, u.addr_state=ai.addr_state, u.zip=ai.zip, u.lat=ai.lat, u.lng=ai.lng') 
  end
end
