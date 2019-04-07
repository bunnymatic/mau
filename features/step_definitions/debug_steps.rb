# frozen_string_literal: true

Then(/^I (sleep|wait) "(\d+)" seconds?$/) do |_dummy, secs|
  sleep(secs.to_i)
end

Then(/^I debug$/) do
  debugger
end

Then /^show me the os info$/ do
  puts 'artists', Artist.active.count

  puts 'cur', OpenStudiosEventService.current.key
  puts 'cu2r', OpenStudiosEvent.current.key
  puts 'keys', OpenStudiosEvent.all.map(&:inspect)
  puts 'os artists', Artist.active.select(&:doing_open_studios?).count
  puts 'os', (Artist.active.map { |a| a.artist_info.os_participation })
end
