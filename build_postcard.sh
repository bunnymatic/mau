#!/usr/bin/env ruby

# Read postcard_thoughts.md for details
artist_id = $ARGV[0]
template_url = $ARGV[1]

art_piece = Artist.find(artist_id).representative_piece

puts art_piece

tmp = ImageProcessing::BaseCardBuilder.build(art_piece, template_url)

dest = "/Users/jon/projects/mau/postcard.png"

puts "Created #{tmp}"
puts "Copying to #{dest}"
FileUtils.cp(tmp, dest)
puts "Done"



