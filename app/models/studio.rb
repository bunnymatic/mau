# frozen_string_literal: true
require 'uri'
class Studio < ApplicationRecord
  include AddressMixin
  include Geokit::ActsAsMappable

  include Elasticsearch::Model

  __elasticsearch__.client = Search::EsClient.root_es_client

  settings(analysis: Search::Indexer::ANALYZERS_TOKENIZERS, index: { number_of_shards: 2 }) do
    mappings(_all: { analyzer: :mau_snowball_analyzer }) do
      indexes :name, analyzer: :mau_snowball_analyzer
      indexes :address, analyzer: :mau_snowball_analyzer
    end
  end

  after_commit :add_to_search_index, on: :create
  after_commit :refresh_in_search_index, on: :update
  after_commit :remove_from_search_index, on: :destroy

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def refresh_in_search_index
    Search::Indexer.reindex(self)
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end

  extend FriendlyId
  friendly_id :name, use: [:slugged]

  has_many :artists

  acts_as_mappable
  before_create :compute_geocode
  before_update :compute_geocode
  before_save :normalize_phone_number

  validates :name, presence: true, uniqueness: true
  validates :street, presence: true

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''

  validates_attachment_presence :photo
  validates_attachment_content_type :photo, content_type: %r{\Aimage\/.*\Z}, if: :"photo?"

  def self.by_position
    order('position, lower(name)')
  end

  SORT_BY_NAME = lambda do |a, b|
    if a.nil?
      1
    elsif b.nil?
      -1
    else
      a.name.downcase.gsub(/^the /, '') <=> b.name.downcase.gsub(/^the /, '')
    end
  end

  def to_param
    slug || id
  end

  def normalize_phone_number
    phone&.gsub!(/\D+/, '')
  end

  def as_indexed_json(_opts = {})
    idxd = as_json(only: [:name, :slug])
    extras = {}
    extras['address'] = address.to_s
    extras['images'] = image_paths
    extras['os_participant'] = artists.any? { |a| a.try(:doing_open_studios?) }
    idxd['studio'].merge!(extras)
    idxd
  end

  # return faux indy studio
  def self.indy
    IndependentStudio.new
  end

  def get_profile_image(size)
    photo? ? photo(size) : StudioImage.get_path(self, size)
  end

  def image_paths
    @image_paths ||= StudioImage.paths(self)
  end
end
