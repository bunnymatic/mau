require 'uri'
class Studio < ApplicationRecord
  include PhoneNumberMixin
  include AddressMixin
  include Geokit::ActsAsMappable

  include Elasticsearch::Model

  __elasticsearch__.client = Search::EsClient.root_es_client

  index_name name.underscore.pluralize
  document_type name.underscore

  settings(
    analysis: Search::Indexer::ANALYZERS_TOKENIZERS,
    index: Search::Indexer::INDEX_SETTINGS,
  ) do
    mappings(dynamic: false) do
      indexes :"studio.name", analyzer: :mau_ngram_analyzer
      indexes :"studio.address", analyzer: :mau_ngram_analyzer
    end
  end

  before_validation :normalize_attributes
  before_create :compute_geocode
  before_update :compute_geocode
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

  has_many :artists, dependent: :nullify

  acts_as_mappable

  validates :name, presence: true, uniqueness: { case_sensitive: true }
  validates :street, presence: true
  validates :phone, phone_number: true, allow_nil: true

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''

  validates_attachment_presence :photo
  validates_attachment_content_type :photo, content_type: %r{\Aimage/.*\Z}, if: :photo?

  def self.by_position
    order(
      arel_table[:position],
      Arel::Nodes::NamedFunction.new('lower', [arel_table[:name]]),
    )
  end

  SORT_BY_NAME = lambda do |a, b|
    if a.nil?
      1
    elsif b.nil?
      -1
    else
      a.name.downcase.delete_prefix('the ') <=> b.name.downcase.delete_prefix('the ')
    end
  end

  def to_param
    slug || id
  end

  def as_indexed_json(_opts = {})
    idxd = as_json(only: %i[name slug])
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
    photo(size)
  end

  def image_paths
    @image_paths ||= StudioImage.paths(self)
  end

  def normalize_attributes
    self.phone = normalize_phone_number(phone)
  end
end
