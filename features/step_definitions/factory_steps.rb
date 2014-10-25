Given(/^an account has been created/) do
  @artist = Artist.where(:login => 'bmatic').first
  if !@artist
    @artist = FactoryGirl.create(:artist, :active, :with_art, :login => 'bmatic')
  end
  @artist.password = 'bmatic'
  @artist.password_confirmation = 'bmatic'
  @artist.save!
end

Given(/^an "(.*?)" account has been created/) do |role|
  @artist = FactoryGirl.create(:artist, :active, :with_art, role.to_sym )
  @artist.password = 'bmatic'
  @artist.password_confirmation = 'bmatic'
  @artist.save!
end

Given /there are artists with art in the system/ do
  @artists = FactoryGirl.create_list(:artist, 3, :with_art, :with_studio, :number_of_art_pieces => 5)
  @art_pieces = @artists.map(&:art_pieces).flatten
end

Given /there are application events in the system/ do
  ApplicationEvent.destroy_all
  @application_events = [
                         FactoryGirl.create(:open_studios_signup_event),
                         FactoryGirl.create(:generic_event)
                        ]
end

Given /there are open studios artists with art in the system/ do
  steps %{Given there are artists with art in the system}
  @artists.each{|a| a.update_os_participation(Conf.os_live, true) }
end

Given /there is open studios cms content in the system/ do

  args = {:page => :main_openstudios, :section => :preview_reception}
  @os_reception_content ||= (CmsDocument.where(args).first || FactoryGirl.create(:cms_document, args))

  args = {:page => :main_openstudios, :section => :summary}
  @os_summary_content ||= (CmsDocument.where(args).first || FactoryGirl.create(:cms_document, args))

end

Given /there are users in the system/ do
  @users = FactoryGirl.create_list(:user, 4)
end

Given /there are tags on the art/ do
  @art_piece_tags = FactoryGirl.create_list(:art_piece_tag, 10)
  @art_pieces.each_with_index do |art, idx|
    art.tags = @art_piece_tags.sample([idx,10].min) + [@art_piece_tags.first]
    art.save!
  end
end

Given /there are events in the system/ do
  Event.destroy_all
  @events = [ FactoryGirl.create_list(:event, 5, :published),
              FactoryGirl.create_list(:event, 5, :with_reception, :published),
              FactoryGirl.create_list(:event, 5),
            ].flatten
  @published_events = @events.select{|ev| ev.published_at.present?}
end

Given /there are past open studios events/ do
  (@open_studios_events ||= []) << FactoryGirl.create(:open_studios_event, :start_date => 3.months.ago)
end

Given /there are future open studios events/ do
  (@open_studios_events ||= []) << FactoryGirl.create(:open_studios_event, :start_date => 3.months.since)
end
