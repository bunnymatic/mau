# frozen_string_literal: true

class CreateSitePreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :site_preferences do |t|
      t.string :social_media_tags

      t.timestamps
    end
  end
end
