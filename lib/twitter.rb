class TwitterEntry
  attr_accessor :description
  attr_accessor :date
  def title
    self.description
  end
end
class TwitterChannel
  attr_accessor :title
end
class TwitterFeed 
  attr_accessor :channel
  attr_accessor :items
  def initialize(json=nil)
    if json 
      twitter_data = JSON.parse(json)
      twitter_data.each do |tweet|
        self.channel = TwitterChannel.new
        self.channel.title = "Twitter: " + tweet['user']['screen_name']
        entry = TwitterEntry.new
        entry.description = tweet["text"]
        entry.date = Date.parse(tweet['created_at'])
        if !self.items:
            self.items = []
        end
        self.items << entry
      end
    end
  end
end
