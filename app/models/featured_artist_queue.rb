class FeaturedArtistQueue < ActiveRecord::Base
  
  default_scope :order => 'position'
  named_scope :not_yet_featured, :conditions => 'featured is NULL'
  named_scope :featured, :conditions => 'featured is not NULL'
  
  TABLE_NAME = 'featured_artist_queue'
  set_table_name TABLE_NAME
  
  FEATURE_LIFETIME = 1.week

  def self.reset_queue
    self.connection.execute("update #{TABLE_NAME} set featured=NULL, position=rand()")
  end

  def self.next_artist
    reset_queue if not_yet_featured.count == 0
    a = nil
    current_featured_artist = featured.all(:order => 'featured desc').first
    if current_featured_artist
      # we found a featured item
      if (Time.now - current_featured_artist.featured) < FEATURE_LIFETIME
        return Artist.find(current_featured_artist.artist_id)
      end
    end
    # get a new artist
    a = not_yet_featured.first
    a.update_attributes(:featured => Time.now())
    a.artist
  end

  def artist
    Artist.find(artist_id)
  end

end
