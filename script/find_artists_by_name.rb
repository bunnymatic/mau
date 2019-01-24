#!/usr/bin/env ruby
# frozen_string_literal: true

puts 'Searching...'
artists = []
$stdin.read.split("\n").each do |line|
  next if line.blank? || (line =~ /^#/)

  line.split(',').each do |item|
    name_bits = item.split
    next if name_bits.length < 2

    a = Artist.find_by(firstname: name_bits[0].downcase, lastname: name_bits[1].downcase)
    artists << a if a
  end
end
puts "Found #{artists.count} artists that match"
artists.map { |a| "#{a.get_name}\t#{a.get_share_link}\t#{a.qrcode}" }.each do |astr|
  puts astr
end
