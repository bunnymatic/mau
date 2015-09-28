class AddAttachmentToStudio < ActiveRecord::Migration
  def change
    add_attachment :studios, :photo
  end
end
