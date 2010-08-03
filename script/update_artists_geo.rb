#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require 'geokit'
Rails::Initializer.run do |config|
end


studios = Studio.find(:all)
studios.each do |s|
  if (!s.lat || !s.lng) 
    # updates geocode
    p "Updating %s" % s.name
    s.save()
    # wait between calls
    sleep(1)
  else 
    p "Already geocoded %s" % s.name
  end
end

Studio.flush_cache

artists = Artist.find(:all, :conditions => "state = 'active'")
artists.each do |a|
  # updates geocode
  p "Updating %s" % a.fullname
  a.save()
  # wait between calls
  sleep(1)
end

Artist.flush_cache
