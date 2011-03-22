class Tag < ActiveRecord::Base
  has_many_polymorphs :taggables, 
  :from => [:events],
  :through => :taggings,
  :dependent => :destroy
end
