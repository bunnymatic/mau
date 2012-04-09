#!/usr/bin/env ruby


puts "Searching..."
artists = []
$stdin.read.split("\n").each do |line|
  next if line.blank?
  next if /^#/.match(line)
  line.split(',').each do |item|
    name_bits = item.split
    next if name_bits.length < 2
    a = Artist.find_by_firstname_and_lastname(name_bits[0].downcase, name_bits[1].downcase)
    if a
      artists << a
    end
  end
end
puts "Found #{artists.count} artists that match"
artists.map{|a| "#{a.get_name}\t#{a.get_share_link}\t#{a.qrcode}"}.each do |astr|
  puts astr
end

