# == Schema Information
#
# Table name: artist_infos
#
#  id                         :integer          not null, primary key
#  artist_id                  :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  bio                        :text
#  news                       :text
#  street                     :string(255)
#  city                       :string(200)
#  addr_state                 :string(4)
#  facebook                   :string(200)
#  twitter                    :string(200)
#  blog                       :string(200)
#  myspace                    :string(200)
#  flickr                     :string(200)
#  zip                        :integer
#  max_pieces                 :integer          default(20)
#  studionumber               :string(255)
#  lat                        :float
#  lng                        :float
#  open_studios_participation :string(255)
#
# Indexes
#
#  index_artist_infos_on_artist_id  (artist_id)
#

class ArtistInfo < ActiveRecord::Base
  belongs_to :artist

  acts_as_mappable
  before_validation(:on => :create){ compute_geocode }
  before_validation(:on => :update){ compute_geocode }

  include AddressMixin

  def os_participation
    if open_studios_participation.blank? || !Conf.oslive
      {}
    else
      parse_open_studios_participation(self.open_studios_participation) || {}
    end
  end

  def update_os_participation(key,value)
    self.os_participation = Hash[key.to_s,value]
  end

private
  def os_participation=(os)
    current = parse_open_studios_participation(self.open_studios_participation)
    current.merge!(os)
    current.delete_if{ |k,v| !(v=='true' || v==true || v=='on' || v=='1' || v==1) }
    update_attribute(:open_studios_participation, current.keys.join('|'))
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
