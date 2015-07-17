require 'ap'

Then(/^I debug$/) do
  binding.pry
end

Then /^show me the os info$/ do
  ap OpenStudiosEventService.current.inspect
  ap OpenStudiosEvent.current.inspect
  puts "artists", Artist.active.count
  puts "os artists", Artist.active.select(&:doing_open_studios?).count
end
  
       
