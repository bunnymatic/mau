class Artist < User
  BOUNDS = { 'NW' => [ 37.76978184422388, -122.42683410644531 ],
    'NE' => [ 37.76978184422388, -122.40539789199829 ],
    'SW' => [ 37.747787573475506, -122.42919445037842 ],
    'SE' => [ 37.74707496171992, -122.40539789199829 ] }

  named_scope :open_studios_participants, lambda { |*oskey| 
      if oskey.blank?
        {
        :joins => :artist_info, 
        :conditions => ["artist_infos.open_studios_participation like '%%201104%%'"] 
        }
      else
        {
        :joins => :artist_info, 
        :conditions => ["artist_infos.open_studios_participation like '%%#{oskey}%%'"] 
        }
      end
    }
  
  #named_scope :in_the_mission, :joins => [:artist_info, :studio], :conditions => [Artist.bounds_clause('artist_infos') + " or " + Artist.bounds_clause('studios')]

  has_one :artist_info

  has_many :art_pieces, :order => "`order` ASC, `id` DESC"

  before_create :make_activation_code

  [:representative_piece, 
   :bio, :bio=,
   :os2010, 
   :osoct2010,
   :facebook, :facebook=,
   :flickr, :flickr=,
   :twitter, :twitter=,
   :blog, :blog=,
   :myspace, :myspace=,
   :os_participation, :os_participation=
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

  def in_the_mission?
    h = self.address_hash
    if h && h.has_key?(:latlng)
      lat = h[:latlng][0]
      lng = h[:latlng][1]
      sw = BOUNDS['SW']
      ne = BOUNDS['NE']
      if lat && lng
        (lat>sw[0] and lat<ne[0] and lng>sw[1] and lng<ne[1])
      else
        false
      end
    else
      false
    end
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
