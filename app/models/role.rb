class Role < ActiveRecord::Base
  has_and_belongs_to_many :artists

  #add validation for good measure  
  validates_presence_of :role
  validates_uniqueness_of :role


  def self.[](role)
    find_first(['role = ?', role])
  end
end

