class AddAttachmentToStudio < ActiveRecord::Migration
  def up
    add_attachment :studios, :photo
  end
  def down
    add_attachment :studios, :photo
  end
end
