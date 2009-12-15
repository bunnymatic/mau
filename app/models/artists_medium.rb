class ArtistsMedium < ActiveRecord::Base
  belongs_to :artist
  belongs_to :medium
end
