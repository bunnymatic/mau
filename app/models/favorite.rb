class Favorite < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :favorites
  belongs_to :favoritable, polymorphic: true

  validate :uniqueness_of_owner_and_item

  scope :art_pieces, -> { where(favoritable_type: ArtPiece.name) }
  scope :artists, -> { where(favoritable_type: Artist.name) }
  scope :by_recency, -> { order(created_at: :desc) }
  scope :active_owners, -> { includes(:owner).where(owner: { state: 'active' }) }
  FAVORITABLE_TYPES = %w[Artist ArtPiece].freeze

  def uniqueness_of_owner_and_item
    return unless Favorite.exists?(owner:, favoritable_type:, favoritable_id:)

    errors.add(:owner, 'You have already favorited that item')
  end
end
