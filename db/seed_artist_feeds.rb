#!/usr/bin/env ruby

feeds = [{"url"=>"http://flaxart.com", "feed"=>"http://flaxart.com/feed"}, {"url"=>"http://risingartist.blogspot.com/", "feed"=>"http://feeds.feedburner.com/RisingArtist"}, {"url"=>"http://missionlocal.org/category/the-arts/", "feed"=>"http://missionlocal.org/category/the-arts/feed/"}, {"url"=>"http://twitter.com/sfmau", "feed"=>"http://twitter.com/statuses/user_timeline/62131363.json"}, {"url"=>"http://twitter.com/bunnymaticsf", "feed"=>"http://twitter.com/statuses/user_timeline/32943864.json"}, {"url"=>"http://sfartnews.wordpress.com/", "feed"=>"http://sfartnews.wordpress.com/feed/"}, {"url"=>"http://trishtunney.blogspot.com/", "feed"=>"http://trishtunney.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://catherine-mackey.blogspot.com/", "feed"=>"http://catherine-mackey.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://apaintingaday.blogspot.com/", "feed"=>"http://apaintingaday.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://katjaleibenath.blogspot.com", "feed"=>"http://katjaleibenath.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://estudiomartita.blogspot.com/", "feed"=>"http://estudiomartita.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://clarussell.blogspot.com/", "feed"=>"http://clarussell.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://studiomorin.blogspot.com/", "feed"=>"http://studiomorin.blogspot.com/feeds/posts/default?alt=rss"}, {"url"=>"http://ordinaryknitting.blogspot.com/", "feed"=>"http://ordinaryknitting.blogspot.com/feeds/posts/default?alt=rss"}]

feeds.each do |feed|
  feed['active'] = true
  ArtistFeed.create(feed)
end

