class CreateBlacklistDomains < ActiveRecord::Migration
  def self.up
    create_table :blacklist_domains do |t|
      t.string :domain
      t.timestamps
    end
  end

  def self.down
    drop_table :blacklist_domains
  end
end
