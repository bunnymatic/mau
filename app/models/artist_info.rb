# frozen_string_literal: true
class ArtistInfo < ApplicationRecord
  belongs_to :artist

  include Geokit::ActsAsMappable
  acts_as_mappable
  before_validation(on: :create) { compute_geocode }
  before_validation(on: :update) { compute_geocode }

  validates :artist_id, presence: true, uniqueness: true

  include AddressMixin
  include OpenStudiosEventShim

  def os_participation
    @os_participation ||=
      begin
        if open_studios_participation.blank? || !current_open_studios_key
          {}
        else
          parse_open_studios_participation(self.open_studios_participation) || {}
        end
      end
  end

  def update_os_participation(os, value)
    key = if os.is_a? OpenStudiosEvent
            os.key
          else
            os
          end

    self.os_participation = Hash[key.to_s, value]
  end

  private

  def os_participation=(os)
    current = parse_open_studios_participation(self.open_studios_participation)
    current.merge!(os)
    current.delete_if { |_k, v| !(v == 'true' || v == true || v == 'on' || v == '1' || v == 1) }
    update_attributes(open_studios_participation: current.keys.join('|'))
  end

  def parse_open_studios_participation(os)
    if os.blank?
      {}
    else
      Hash[os.split('|').select { |k| k.match(/^[\w\d]/) }.map { |k| [k, true] }]
    end
  end
end
