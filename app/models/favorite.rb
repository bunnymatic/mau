class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorite, :polymorphic => true

  named_scope :art_pieces, lambda { 
    { :conditions => [ "favoritable_type = ?", ArtPiece.name ] } 
  }
  named_scope :users,  lambda { 
    { :conditions => ["favoritable_type in (?)", [Artist.name, User.name]] }
  }
  named_scope :artists, lambda {
    { :conditions => ["favoritable_type = ?", Artist.name] }
  }
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
