class ArtistsEvent < ActiveRecord::Base
  belongs_to :artist
  belongs_to :event
end
