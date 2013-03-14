[FeedbackMailerList, EventMailerList, AdminMailerList].each do |mailing_list|
  begin
    if mailing_list.all.empty?
      puts "Creating #{mailing_list.name} list"
      mailing_list.create
    end
  rescue Exception => ex
    RAILS_DEFAULT_LOGGER.debug("Failed to create #{mailing_list.name} : #{ex}")
  end
end
