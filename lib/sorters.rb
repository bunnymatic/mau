module Sorters
  def self.studio_name 
    lambda{|a,b| 
      a.name.downcase.gsub(/^the /,'') <=> b.name.downcase.gsub(/^the /,'')
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
