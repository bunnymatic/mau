class Artist < User
  has_one :artist_info
  
  delegate :representative_piece, :to => :artist_info, :allow_nil => true

  delegate :facebook, :to => :artist_info
  delegate :flickr, :to => :artist_info
  delegate :twitter, :to => :artist_info
  delegate :blog, :to => :artist_info
  delegate :myspace, :to => :artist_info


  def self.find_all_by_fullname( names )
    inclause = ""
    lower_names = names.map { |n| n.downcase }
    sql = "select * from users where (lower(concat_ws(' ', firstname, lastname)) in (?)) and type='Artist'"
    find_by_sql [sql, lower_names]
  end

  def self.find_by_fullname( name )
    find_all_by_fullname([name])
  end

end
