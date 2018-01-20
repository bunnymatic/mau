# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favorite, polymorphic: true

  validate :uniqueness_of_user_and_item

  scope :art_pieces, -> { where(favoritable_type: ArtPiece.name) }
  scope :users, -> { where(favoritable_type: [Artist.name, User.name]) }
  scope :artists, -> { where(favoritable_type: Artist.name) }

  FAVORITABLE_TYPES = %w[Artist ArtPiece].freeze

  def uniqueness_of_user_and_item
    duplicate = self.class.find_by(user: user, favoritable_type: favoritable_type, favoritable_id: favoritable_id)
    errors.add(:user, 'You have already favorited that item') if duplicate
  end

  def art_piece?
    favoritable_type == ArtPiece.name
  end

  def artist?
    favoritable_type == Artist.name
  end

  def to_obj
    return nil unless FAVORITABLE_TYPES.include? favoritable_type
    begin
      favoritable_type.constantize.find(favoritable_id)
    rescue ActiveRecord::RecordNotFound
      destroy
      nil
    end
  end
end
