
[FeedbackMailerList, EventMailerList, AdminMailerList].each do |mailing_list|
  begin
    puts "Creating #{mailing_list.name} list"
    mailing_list.create
  rescue Exception => ex
    RAILS_DEFAULT_LOGGER.debug("Failed to create #{mailing_list.name} : #{ex}")
  end
end
