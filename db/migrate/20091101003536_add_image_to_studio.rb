class AddImageToStudio < ActiveRecord::Migration
  def self.up
    add_column :studios, :profile_image, :string
    memcache_options = {
      :c_threshold => 10_000,
      :compression => true,
      :debug => false,
      :namespace => 'mau',
      :readonly => false,
      :urlencode => false
    }

    begin
       cache = MemCache.new memcache_options
       cache.servers = 'localhost:11211'
       cache.delete('studios')
    rescue
       p "Failed to delete studio memcache"
    end
  end

  def self.down
    remove_column :studios, :profile_image
  end
end
