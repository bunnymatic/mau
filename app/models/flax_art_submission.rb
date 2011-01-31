class FlaxArtSubmission < ActiveRecord::Base
  
  validates_presence_of :user_id
  validates_presence_of :art_piece_ids
  validates_length_of :art_piece_ids, :minimum => 1, :allow_nil => false

end
