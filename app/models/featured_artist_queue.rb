class FeaturedArtistQueue < ActiveRecord::Base

  TABLE_NAME = 'featured_artist_queue'
  self.table_name = TABLE_NAME
  scope :by_position, -> { order(:position) }
  scope :not_yet_featured, -> { where('featured is NULL').by_position }
  scope :featured, -> { where('featured is not NULL').order('featured desc') }

  belongs_to :artist

  FEATURE_LIFETIME = 1.week

  def self.reset_queue
    self.connection.execute("update #{TABLE_NAME} set featured=NULL, position=rand()")
  end

  def self.current_entry
    if featured.count <= 0
      next_entry
    else
      featured.all.take
    end
  end

  def self.next_entry(override = false)
    reset_queue if not_yet_featured.count == 0
    a = nil
    current_featured_artist = featured.all.take
    if current_featured_artist && !override
      # we found a featured item
      if ((Time.zone.now - current_featured_artist.featured) < FEATURE_LIFETIME)
        return current_featured_artist
      end
    end
    # get a new artist
    a = not_yet_featured.where('artist_id is not null').first
    if a
      a.update_attributes!(:featured => Time.zone.now)
      a
    end
  end

end
