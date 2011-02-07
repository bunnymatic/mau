class AddEditorToRoles < ActiveRecord::Migration
  def self.up
    execute "insert into roles (role, created_at, updated_at) values('editor', now(), now())"
  end

  def self.down
    execute "delete from roles where role='editor'"
  end
end
