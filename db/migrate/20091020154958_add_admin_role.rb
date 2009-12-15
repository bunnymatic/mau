class AddAdminRole < ActiveRecord::Migration
  def self.up
    r = nil
    begin
      r = Role.find(1)
    rescue
    end
    if not r
      r = Role.new
      r.role="admin"
      r.id=1
      r.save
    end
  end

  def self.down
  end
end
