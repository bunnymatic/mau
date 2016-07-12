class ArtPieceTag < ActiveRecord::Base

  has_many :art_pieces_tags
  has_many :art_pieces, through: :art_pieces_tags

  include FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  validates :name, presence: true, length: { within: 3..25 }

  scope :alpha, -> { order('name') }

  def safe_name
    HtmlEncoder.encode(self.name).gsub(' ', '&nbsp;').html_safe
  end

end
