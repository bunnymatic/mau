#!/usr/bin/env ruby
require "#{File.dirname(__FILE__)}/../config/boot"
require 'geokit'
Rails::Initializer.run do |config|
end

Studio.all.each do |s|
  if !s.lat || !s.lng
    # updates geocode
    p "Updating #{s.name}"
    s.save
    # wait between calls
    sleep(1)
  else
    p "Already geocoded 1#{s.name}"
  end
end

Artist.active.all.each do |a|
  # updates geocode
  if !a.lat || !a.lng
    p "Updating #{a.fullname}"
    a.save
    # wait between calls
    sleep(1)
  else
    p "Already updated #{a.fullname}"
  end
end
