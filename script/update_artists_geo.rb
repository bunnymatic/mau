#!/usr/bin/env ruby
# frozen_string_literal: true
require File.dirname(__FILE__) + '/../config/boot'
require 'geokit'
Rails::Initializer.run do |config|
end

studios = Studio.find(:all)
studios.each do |s|
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

artists = Artist.find(:all, conditions: "state = 'active'")
artists.each do |a|
  # updates geocode
  if a && !a.lat || !a.lng
    p "Updating #{a.fullname}"
    a.save
    # wait between calls
    sleep(1)
  else
    p "Already updated #{a.fullname}"
  end
end
