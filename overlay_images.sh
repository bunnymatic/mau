#!/usr/bin/env ruby

file1 = $ARGV[0]
file2 = $ARGV[1]

puts "Combining #{file1} with #{file2}"

tmp = ImageProcessing::ImageProcessor.combine(
  file1,
  file2,
  offset: ImageProcessing::Offset.new(x: 0, y: -300)
)
dest = "/Users/jon/projects/mau/tmp/capybara/combo.png"

puts "Created #{tmp}"
puts "Copying to #{dest}"
FileUtils.cp(tmp, dest)
puts "Done"



