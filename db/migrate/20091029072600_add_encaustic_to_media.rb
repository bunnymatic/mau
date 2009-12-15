class AddEncausticToMedia < ActiveRecord::Migration
  def self.add_medium(name)
    if not Medium.find_by_name(name)
      Medium.new(:name=>name).save
    else
      puts "Medium " + name + " has already been added"
    end
  end
  def self.up
    puts "Adding media"
    self.add_medium('Painting - Encaustic')
  end

  def self.down
  end
end
