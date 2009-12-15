begin
require 'mojo_magick'
rescue
p "MojoMagick is not available. Migration will do nothing."
end
class PopulateStudioHtWt < ActiveRecord::Migration
  def self.up
    # use find(:all) because .all is cached
    Studio.find(:all).each do |s|
      # check format
      fname = s.profile_image
      begin
        sz = MojoMagick::raw_command('identify','-format "%h %w" public/' + fname)
        (height, width) = sz.split(' ')
        s.image_height = height.to_i
        s.image_width = width.to_i
        s.save
      rescue
        p "Failed to get size for studio profile image %s (%s)" % [fname, $!]
      end
    end
  end

  def self.down
  end
end
