class ArtistInfo < ActiveRecord::Base
  belongs_to :artist

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode

  include AddressMixin

  def os_participation
    if self.open_studios_participation.blank? || !Conf.oslive
      {}
    else 
      parse_open_studios_participation(self.open_studios_participation)
    end
  end

  def update_os_participation(key,value)
    self.os_participation = Hash[key.to_s,value]
    self.save
  end

  def os_participation=(os)
    current = parse_open_studios_participation(self.open_studios_participation)
    current.merge!(os)
    current.delete_if{ |k,v| !(v=='true' || v==true || v=='on' || v=='1' || v==1) }
    self.open_studios_participation = current.keys.join('|')
  end

  private 
  def parse_open_studios_participation(os)
    if os.blank?
      {}
    else
      Hash[ os.split('|').select{|k| k.match(/^[\w\d]/)}.map{ |k| [k,true] }]
    end
  end

end
