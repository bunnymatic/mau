begin
require 'mojo_magick'
rescue
p "MojoMagick is not available. Migration will do nothing."
end
class PopulateHtWd < ActiveRecord::Migration
  def self.up
    # use find(:all) because .all is cached
    ArtPiece.find(:all).each do |ap|
      # check format
      fname = ap.filename
      begin
        sz = MojoMagick::raw_command('identify','-format "%h %w" public/' + fname)
        (height, width) = sz.split(' ')
        ap.image_height = height.to_i
        ap.image_width = width.to_i
        ap.save
      rescue
        p "Failed to get size for image %s (%s)" % [fname, $!]
      end
    end

    # use find(:all) because .all is cached
    Artist.find(:all).each do |art|
      # check format
      fname = art.profile_image
      begin
        sz = MojoMagick::raw_command('identify','-format "%h %w" public/' + fname)
        (height, width) = sz.split(' ')
        art.image_height = height.to_i
        art.image_width = width.to_i
        art.save
      rescue
        p "Failed to get size for image %s (%s)" % [fname, $!]
      end
    end
  end

  def self.down
  end
end
