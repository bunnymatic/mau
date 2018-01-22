# frozen_string_literal: true

# add old open studios events to the system

# [2010,2011,2012,2013,2014].each do |year|
#   [4,10].each do |month|
#     start_date = Time.new(:year => year, :month => month, :day => 15)
#     end_date = start_date + 1.day
#     OpenStudiosEvent.create!(:start_date => start_date, :end_date => end_date)
#   end
# end
[
  'Book Arts',
  'Ceramic',
  'Drawing',
  'Digital Art',
  'Fiber/Textile',
  'Furniture',
  'Glass',
  'Glass/Ceramics',
  'Gouache',
  'Jewelry',
  'Mixed-Media',
  'Painting - Acrylic',
  'Painting - Encaustic',
  'Painting - Oil',
  'Painting - Watercolor',
  'Pastels',
  'Photography',
  'Printmaking',
  'Sculpture'
].each do |name|
  Medium.find_or_create_by(name: name)
end

# Not including RecruitingMailerList
["FeedbackMailerList", "AdminMailerList"].each do |type|
  EmailList.find_or_create_by(type: type)
end
