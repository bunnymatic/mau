class PopulateMedia < ActiveRecord::Migration

  def self.add_medium(name)
    if not Medium.find_by_name(name)
      Medium.new(:name=>name).save
    else
      puts "Medium " + name + " has already been added"
    end
  end
  def self.up
    puts "Adding media"
    self.add_medium('Drawing')
    self.add_medium('Mixed-Media')
    self.add_medium('Photography')
    self.add_medium('Glass/Ceramics')
    self.add_medium('Printmaking')
    self.add_medium('Painting - Oil')
    self.add_medium('Painting - Acrylic')
    self.add_medium('Painting - Watercolor')
    self.add_medium('Sculpture')
    self.add_medium('Jewelry')
    self.add_medium('Fiber/Textile')
    self.add_medium('Furniture')
    self.add_medium('Books') 
  end

  def self.down
  end
end
