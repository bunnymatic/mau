class FeaturedArtistQueue < ActiveRecord::Base
  
  default_scope :order => 'position'
  named_scope :not_yet_featured, :conditions => 'featured is NULL'
  named_scope :featured, :conditions => 'featured is not NULL', :order => 'featured desc'
  
  TABLE_NAME = 'featured_artist_queue'
  set_table_name TABLE_NAME
  
  FEATURE_LIFETIME = 1.week

  def self.reset_queue
    self.connection.execute("update #{TABLE_NAME} set featured=NULL, position=rand()")
  end

  def self.current_entry
    if featured.count <= 0 
      next_entry
    else
      featured.all(:limit => 1).first
    end
  end

  def self.next_entry(override = false)
    reset_queue if not_yet_featured.count == 0
    a = nil
    current_featured_artist = featured.all(:limit => 1).first
    if current_featured_artist && !override
      # we found a featured item
      if ((Time.zone.now - current_featured_artist.featured) < FEATURE_LIFETIME)
        return current_featured_artist
      end
    end
    # get a new artist
    a = not_yet_featured.first
    if a 
      a.update_attributes(:featured => Time.zone.now)
      a
    end
  end

  def artist
    Artist.find(artist_id)
  end

end
