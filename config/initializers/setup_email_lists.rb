["FeedbackMailerList", "AdminMailerList"].each do |mailing_list|
  begin
    if mailing_list.constantize.all.empty?
      puts "Creating #{mailing_list} list"
      mailing_list.constantize.create
    end
  rescue Exception => ex
    ::Rails.logger.debug("Failed to create #{mailing_list} : #{ex}")
  end
end
