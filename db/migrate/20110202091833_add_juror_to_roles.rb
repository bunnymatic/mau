class AddJurorToRoles < ActiveRecord::Migration
  def self.up
    execute "insert into roles (role, created_at, updated_at) values('jurors', now(), now())"
  end

  def self.down
    execute "delete from roles where role='jurors'"
  end
end
