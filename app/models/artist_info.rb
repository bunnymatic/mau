# frozen_string_literal: true

class ArtistInfo < ApplicationRecord
  belongs_to :artist

  include Geokit::ActsAsMappable
  acts_as_mappable
  before_validation(on: :create) { compute_geocode }
  before_validation(on: :update) { compute_geocode }

  validates :artist_id, presence: true, uniqueness: true

  include AddressMixin
end
