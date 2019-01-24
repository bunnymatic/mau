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
          parse_open_studios_participation(open_studios_participation) || {}
        end
      end
  end

  def update_os_participation(open_studios_event, value)
    key = open_studios_event.is_a?(OpenStudiosEvent) ? open_studios_event.key : open_studios_event
    self.os_participation = Hash[key.to_s, value]
  end

  private

  def os_participation=(os_setting)
    current = parse_open_studios_participation(open_studios_participation)
    current.merge!(os_setting)
    current.delete_if { |_k, v| !['true', 'on', '1', true, 1].include?(v) }
    update(open_studios_participation: current.keys.join('|'))
  end

  def parse_open_studios_participation(os_string)
    return {} if os_string.blank?

    Hash[os_string.split('|').select { |k| k.match(/^[\w\d]/) }.map { |k| [k, true] }]
  end
end
