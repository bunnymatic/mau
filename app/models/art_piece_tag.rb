# frozen_string_literal: true

class ArtPieceTag < ApplicationRecord
  has_many :art_pieces_tags, dependent: :destroy
  has_many :art_pieces, through: :art_pieces_tags

  include FriendlyId
  friendly_id :name, use: [:slugged]

  validates :name, presence: true, length: { within: 3..25 }

  scope :alpha, -> { order('name') }
end
