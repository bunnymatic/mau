def ensure_open_studios_event(start_date)
  OpenStudiosEvent.find_or_create_by(key: start_date.strftime('%Y%m')) do |os|
    os.assign_attributes(FactoryBot.attributes_for(:open_studios_event, start_date: start_date))
  end
  puts "--> Added Open Studios Event for #{start_date}"
end

ensure_open_studios_event(Time.zone.local(2016, 4, 1))
ensure_open_studios_event(Time.zone.local(2016, 11, 1))
ensure_open_studios_event(Time.zone.local(2017, 4, 1))

OpenStudiosEvent.all.each do |os_event|
  Artist.active.each do |artist|
    artist.open_studios_events << os_event
  rescue ActiveRecord::RecordInvalid => e
    puts "Ran into an issue adding artists to open studios #{e}"
    puts 'Moving on...'
  end
end
