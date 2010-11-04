class Artist < User
  has_one :artist_info
  
  delegate :representative_piece, :to => :artist_info, :allow_nil => true
end
