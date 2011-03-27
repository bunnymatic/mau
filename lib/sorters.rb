module Sorters
  def self.studio_name 
    lambda{|a,b| 
      if a.id == 0
        1
      elsif b.id == 0
        -1
      else
        a.name.downcase.gsub(/^the /,'') <=> b.name.downcase.gsub(/^the /,'')
      end
    }
  end
  def self.artist_lastname 
    lambda{|a,b| 
      a.lastname.downcase <=> b.lastname.downcase 
    }
  end
  def self.artist_firstname 
    lambda{|a,b| 
      a.lastname.downcase <=> b.lastname.downcase 
    }
  end
end
