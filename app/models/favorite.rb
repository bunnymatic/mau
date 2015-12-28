# == Schema Information
#
# Table name: favorites
#
#  id               :integer          not null, primary key
#  created_at       :datetime
#  updated_at       :datetime
#  favoritable_id   :integer
#  favoritable_type :string(255)
#  user_id          :integer
#

class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorite, :polymorphic => true

  scope :art_pieces, -> { where(:favoritable_type => ArtPiece.name) }
  scope :users, -> { where(:favoritable_type => [Artist.name, User.name]) }
  scope :artists, -> { where(:favoritable_type => Artist.name) }

  FAVORITABLE_TYPES = ['Artist','ArtPiece']

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
    if FAVORITABLE_TYPES.include? self.favoritable_type
      begin
        self.favoritable_type.constantize.find(self.favoritable_id)
      rescue ActiveRecord::RecordNotFound
        self.destroy
        nil
      end
    end
  end
end
