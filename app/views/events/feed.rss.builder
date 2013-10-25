xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Mission Artists United Events"
    xml.description "Events and Art Happenings involving Mission Artist United artists"
    xml.link events_url

    for ev in @events
      xml.item do
        xml.title event.title
        xml.description event.description
        xml.pubDate event.promoted_event.publish_date.to_s(:rfc822)
        xml.link event_url(event)
        xml.guid event_url(event)
       end
    end
  end
end
