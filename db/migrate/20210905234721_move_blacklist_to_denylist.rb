class MoveBlacklistToDenylist < ActiveRecord::Migration[6.1]
  def change
    rename_table :blacklist_domains, :denylist_domains
  end
end
