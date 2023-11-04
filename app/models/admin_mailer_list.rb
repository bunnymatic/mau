class AdminMailerList < EmailList
  def self.instance
    first || create
  end
end
