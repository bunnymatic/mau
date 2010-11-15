class Favorite < ActiveRecord::Base
  attr_accessible :obj_id, :obj_type, :user_id
  belongs_to :user
  
  validates_presence_of :obj_id
  validates_presence_of :obj_type
  
  validates_format_of :obj_type, :with => /^(MAUFan|User|Artist|ArtPiece)$/, :message => "must be an allowed favorite type"

  def self.find_by_user(users)
    find_by_sql ['select * from favorites where user_id in (?)', users]
  end
end
