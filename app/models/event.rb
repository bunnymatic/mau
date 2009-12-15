class Event < ActiveRecord::Base
  has_many :artists
  has_many :events, :through => :artists_event
end
