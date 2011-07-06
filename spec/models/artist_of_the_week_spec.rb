require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class FauxCache

  @@CACHE = {}
  def self.read(name, options={})
    return @@CACHE[name]
  end

  def self.write(name, value, options={})
    @@CACHE[name] = value;
  end

  def self.delete(name, options ={} )
    del @CACHE[name]
  end
end

describe ArtistOfTheWeek do
  
end
