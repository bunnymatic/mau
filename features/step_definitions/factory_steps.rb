# frozen_string_literal: true

Given(/^an account has been created/) do
  @artist = Artist.where(login: TestUsersHelper::DEFAULT_LOGIN).first
  @artist ||= FactoryBot.create(:artist, :active, :with_art, :in_the_mission, login: TestUsersHelper::DEFAULT_LOGIN)
  @artist.password = TestUsersHelper::DEFAULT_PASSWORD
  @artist.password_confirmation = TestUsersHelper::DEFAULT_PASSWORD
  @artist.save!
end

Given(/^an? "(.*?)" account has been created/) do |role|
  @artist = FactoryBot.create(:artist, :active, :with_art, role.to_sym)
  @artist.password = TestUsersHelper::DEFAULT_PASSWORD
  @artist.password_confirmation = TestUsersHelper::DEFAULT_PASSWORD
  @artist.save!
end

Given /^there is a studio named "(.*)"$/ do |studio|
  @studio = Studio.find_by(name: studio) || FactoryBot.create(:studio, name: studio)
end

Given /^there is a studio named "(.*)" with artists$/ do |studio|
  Studio.where(name: studio).destroy_all
  @studio = FactoryBot.create(:studio, :with_artists, name: studio, artist_count: 3)
end

Given /there are artists with art in the system$/ do
  @artists = FactoryBot.create_list(:artist, 3, :with_art, :with_studio, number_of_art_pieces: 5)
  @art_pieces = @artists.map(&:art_pieces).flatten
end

Given /there are suspended artists in the system$/ do
  @suspended_artists = FactoryBot.create_list(:artist, 2, :suspended)
end

Given /there are not yet activated artists in the system$/ do
  @pending_artists = FactoryBot.create_list(:artist, 2, :pending)
end

Given /there are artists with art in my studio$/ do
  studio = (@manager || @artist || @user).studio
  FactoryBot.create_list(:artist, 2, :with_art, studio: studio, number_of_art_pieces: 1)
end

Given /the following artists with art are in the system:/ do |table|
  @artists = []
  table.hashes.each do |artist_params|
    args = { number_of_art_pieces: 5 }.merge artist_params
    @artists << FactoryBot.create(:artist, :with_art, :with_studio, args)
  end
  @art_pieces = @artists.compact.map { |a| a.reload.art_pieces }.flatten
end

Given /the following artists who aren't ready to sign up for os are in the system:/ do |table|
  @artists = []
  table.hashes.each do |artist_params|
    args = { number_of_art_pieces: 5 }.merge artist_params
    @artists << FactoryBot.create(:artist, :active, :without_address, args)
  end
  @art_pieces = @artists.map(&:art_pieces).flatten
end

Given /the following admins are in the system:/ do |table|
  table.hashes.each do |user_params|
    FactoryBot.create(:artist, :admin, :active, user_params)
  end
end

Given /there are application events in the system/ do
  ApplicationEvent.destroy_all
  @application_events = [
    FactoryBot.create(:open_studios_signup_event),
    FactoryBot.create(:generic_event),
  ]
end

Given /there is a scheduled Open Studios event/ do
  FactoryBot.create(:open_studios_event)
rescue ActiveRecord::RecordInvalid
  # there's already one there
end

Given /there are open studios artists with art in the system/ do
  steps %(
    Given there are artists with art in the system
    Given there are future open studios events
  )
  @artists.each do |a|
    a.open_studios_events << OpenStudiosEventService.current
    a.artist_info.update_attribute(:lat, 37.75)
    a.artist_info.update_attribute(:lng, -122.41)
    if a.studio
      a.studio.update_attribute(:lat, 37.75)
      a.studio.update_attribute(:lng, -122.41)
    end
  end
end

Given /there is open studios cms content in the system/ do
  args = { page: :main_openstudios, section: :preview_reception }
  @os_reception_content ||= (CmsDocument.where(args).first || FactoryBot.create(:cms_document, args))

  args = { page: :main_openstudios, section: :summary }
  @os_summary_content ||= (CmsDocument.where(args).first || FactoryBot.create(:cms_document, args))
end

Given /there are users in the system/ do
  @users = FactoryBot.create_list(:fan, 4)
end

Given /there are tags on the art/ do
  @art_piece_tags = FactoryBot.create_list(:art_piece_tag, 10)
  @art_pieces.each_with_index do |art, idx|
    art.tags = @art_piece_tags[0..(idx % 10)]
    art.save!
  end
end

Given /there are past open studios events/ do
  (@open_studios_events ||= []) << FactoryBot.create(:open_studios_event, start_date: 3.months.ago)
end

Given /there are future open studios events/ do
  (@open_studios_events ||= []) << (OpenStudiosEventService.current || FactoryBot.create(:open_studios_event, start_date: 3.months.since))
end

Given(/^there are artists and art pieces with favorites$/) do
  step %(there are artists with art in the system)
  step %(there are users in the system)

  @artists = Artist.all
  @users = User.all
  @art_pieces = ArtPiece.all

  @users.each_with_index do |u, idx|
    FavoritesService.add(u, @artists[idx % @artists.count])
  end
  @art_pieces.each_with_index do |ap, idx|
    u = @users[idx % @users.count]
    a = @artists[idx % @artists.count]
    FavoritesService.add(u, ap)
    FavoritesService.add(a, ap) unless ap.artist == a
  end
end

Given /^the email lists have been created with emails$/ do
  %w[FeedbackMailerList AdminMailerList].each do |mailing_list|
    clz = mailing_list.constantize
    begin
      clz.create unless clz.first
    rescue Exception => e
      ::Rails.logger.debug("Failed to create #{mailing_list} : #{e}")
    end
    clz.first.emails.create(name: Faker::Name.name, email: Faker::Internet.email)
  end
end
