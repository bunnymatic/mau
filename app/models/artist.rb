class Artist < User

  has_one :artist_info

  has_many :art_pieces, :order => "`order` ASC, `id` DESC"

  before_create :make_activation_code

  [:representative_piece, :bio, :os2010, :osoct2010,
   :facebook, :flickr, :twitter, :blog, :myspace, 
   :bio=, 
   :facebook=, :flickr=, :twitter=, :blog=, :myspace=, 
   ].each do |delegat|
    delegate delegat, :to => :artist_info, :allow_nil => true
  end

  def self.find_all_by_fullname( names )
    inclause = ""
    lower_names = names.map { |n| n.downcase }
    sql = "select * from users where (lower(concat_ws(' ', firstname, lastname)) in (?)) and type='Artist'"
    find_by_sql [sql, lower_names]
  end

  def self.find_by_fullname( name )
    find_all_by_fullname([name])
  end

  def address
    call_address_method :address
  end
  
  def full_address
    call_address_method :full_address
  end

  def address_hash
    call_address_method :address_hash
  end

  protected
  def call_address_method(method)
    if self.studio_id != 0 and self.studio
      self.studio.send method
    else
      if self.artist_info
        self.artist_info.send method
      end
    end
  end
end
