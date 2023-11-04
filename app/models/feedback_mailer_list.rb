class FeedbackMailerList < EmailList
  def self.instance
    first || create
  end
end
