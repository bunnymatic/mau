class Artist < User
  has_one :artist_info
  
  delegate :representative_piece, :to => :artist_info, :allow_nil => true

  delegate :facebook, :to => :artist_info
  delegate :flickr, :to => :artist_info
  delegate :twitter, :to => :artist_info
  delegate :blog, :to => :artist_info
  delegate :myspace, :to => :artist_info

end
