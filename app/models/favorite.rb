# frozen_string_literal: true
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favorite, polymorphic: true

  validate :uniqueness_of_user_and_item

  scope :art_pieces, -> { where(favoritable_type: ArtPiece.name) }
  scope :users, -> { where(favoritable_type: [Artist.name, User.name]) }
  scope :artists, -> { where(favoritable_type: Artist.name) }

  FAVORITABLE_TYPES = %w(Artist ArtPiece).freeze

  def uniqueness_of_user_and_item
    if self.class.where(user_id: user, favoritable_type: favoritable_type, favoritable_id: favoritable_id).take
      errors.add(:user, 'You have already favorited that item')
    end
  end

  def is_user?
    [Artist.name, User.name].include? favoritable_type
  end

  def is_art_piece?
    favoritable_type == ArtPiece.name
  end

  def is_artist?
    favoritable_type == Artist.name
  end

  def to_obj
    if FAVORITABLE_TYPES.include? favoritable_type
      begin
        favoritable_type.constantize.find(favoritable_id)
      rescue ActiveRecord::RecordNotFound
        destroy
        nil
      end
    end
  end
end
