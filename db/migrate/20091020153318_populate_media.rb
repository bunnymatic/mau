class PopulateMedia < ActiveRecord::Migration

  def self.add_medium(name)
    unless Medium.find_by_name(name)
      Medium.new(:name=>name).save
    else
      puts "Medium " + name + " has already been added"
    end
  end

  def self.up
    ['Drawing'
     'Mixed-Media'
     'Photography'
     'Glass/Ceramics'
     'Printmaking'
     'Painting - Oil'
     'Painting - Acrylic'
     'Painting - Watercolor'
     'Sculpture'
     'Jewelry'
     'Fiber/Textile'
     'Furniture'
     'Books'].each do |m|
      self.add_medium(name)
    end
  end

  def self.down
  end
end
