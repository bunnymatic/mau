class Artist < User
  has_one :artist_info

  has_many :art_pieces, :order => "`order` ASC, `id` DESC"

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode
 
  [:representative_piece, :bio,
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

  protected
    def compute_geocode
      if self.studio_id != 0
        s = self.studio
        if s && s.lat && s.lng
          self.lat = s.lat
          self.lng = s.lng
        end
      else
        # use artist's address
        result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s, %s" % [self.street, self.city || "San Francisco", self.addr_state || "CA", self.zip || "94110"])
        errors.add(:street, "Unable to Geocode your address.") if !result.success
        self.lat, self.lng = result.lat, result.lng if result.success
      end
    end

end
