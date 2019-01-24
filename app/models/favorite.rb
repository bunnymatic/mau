# frozen_string_literal: true

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  validate :uniqueness_of_user_and_item

  scope :art_pieces, -> { where(favoritable_type: ArtPiece.name) }
  scope :users, -> { where(favoritable_type: [Artist.name, User.name]) }
  scope :artists, -> { where(favoritable_type: Artist.name) }
  scope :by_recency, -> { order(created_at: :desc) }

  FAVORITABLE_TYPES = %w[Artist MauFan User ArtPiece].freeze

  def uniqueness_of_user_and_item
    duplicate = self.class.find_by(user: user, favoritable_type: favoritable_type, favoritable_id: favoritable_id)
    errors.add(:user, 'You have already favorited that item') if duplicate
  end

  def art_piece?
    favoritable.is_a? ArtPiece
  end

  def artist?
    favoritable.is_a? User
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
