require 'ap'

Then(/^I debug$/) do
  binding.pry
end

Then /^show me the os info$/ do
  ap OpenStudiosEventService.current.inspect
  ap OpenStudiosEvent.current.inspect
  puts "artists", Artist.active.count

  puts "cur", OpenStudiosEventService.current.key
  puts "cu2r", OpenStudiosEvent.current.key
  puts "keys", OpenStudiosEvent.all.map(&:inspect)
  puts "os artists", Artist.active.select(&:doing_open_studios?).count
  puts "os", Artist.active.map{|a| a.artist_info.os_participation}
end
  
       
