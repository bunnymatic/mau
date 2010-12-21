class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorite, :polymorphic => true

  named_scope :art_pieces, [ "favoritable_type = ?", ArtPiece.class.name ]
  named_scope :users, ["favoritaable_type in ?", [Artist.class.name, User.class.name]]
  named_scope :artists, ["favoritaable_type = ?", Artist.class.name]
  @@FAVORITABLE_TYPES = ['Artist','ArtPiece']

  def to_obj
    if @@FAVORITABLE_TYPES.include? self.favoritable_type
      begin
        self.favoritable_type.constantize.find(self.favoritable_id)
      rescue ActiveRecord::RecordNotFound
        self.destroy
        nil
      end
    end
  end
end
