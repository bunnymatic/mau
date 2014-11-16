atom_feed :language => 'en-US' do |feed|
  feed.title @title
  feed.updated Time.now

  @events.each do |event|
    next unless event.updated_at

    feed.entry( event.event ) do |entry|
      guid = [:tag, request.host, request.fullpath.split('.'), event.event.id].flatten.join(':')
      entry.link href: event_url(event.event)
      entry.title event.title
      entry.content event.feed_description, type: 'html' 
      entry.guid guid

      # the strftime is needed to work with Google Reader.
      # entry.updated(event.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

    end
  end
end
