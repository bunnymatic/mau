class WatcherMailerList < EmailList
  def self.instance
    first || create
  end
end
