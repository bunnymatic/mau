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
  @artists = FactoryBot.create_list(:artist, 3, :with_art, :with_links, :with_studio, number_of_art_pieces: 5)
  @art_pieces = @artists.map(&:art_pieces).flatten
end

Given /there are artists with art in my studio$/ do
  studio = (@manager || @artist || @user).studio
  FactoryBot.create_list(:artist, 2, :with_art, studio:, number_of_art_pieces: 1)
end

Given /the following artists with art are in the system:/ do |table|
  @artists = []
  table.hashes.each do |artist_params|
    @artists << FactoryBot.create(:artist, :with_art, :with_studio, **artist_params, number_of_art_pieces: 5)
  end
  @art_pieces = @artists.compact.map { |a| a.reload.art_pieces }.flatten
end

Given /the following artists who aren't ready to sign up for os are in the system:/ do |table|
  @artists = []
  table.hashes.each do |artist_params|
    @artists << FactoryBot.create(:artist, :active, :without_address, **artist_params, number_of_art_pieces: 5)
  end
  @art_pieces = @artists.map(&:art_pieces).flatten
end

Given /there is a pending artist/ do
  @pending_artist = FactoryBot.create(:artist, :pending)
end

Given /there is a suspended artist/ do
  @suspended_artist = FactoryBot.create(:artist, :suspended)
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

Given /there is a scheduled (active\s+)?Open Studios event/ do |_|
  FactoryBot.create(:open_studios_event, :with_activation_dates, :with_special_event)
rescue ActiveRecord::RecordInvalid
  Rails.logger.warn('Open studios event already exists in this feature.  No problem.')
end

When('there are no active open studios events') do
  OpenStudiosEvent.update!(activated_at: 3.days.ago, deactivated_at: 2.days.ago)
end

When('there is an active open studios without a banner image') do
  @open_studios_event = OpenStudiosEventService.current || create(:open_studios_event, :without_banner_image)
  @open_studios_event.banner_image&.destroy
end

When('there is an active open studios with a banner image') do
  @open_studios_event = create(:open_studios_event, :with_banner_image)
end

Given /the current open studios event has a special event/ do
  os = OpenStudiosEvent.current
  OpenStudiosEvent.current.update(special_event_start_date: os.start_date, special_event_end_date: os.end_date)
  Rails.cache.clear
end

Given /the current open studios is not promoted/ do
  OpenStudiosEvent.current.update!(promote: false)
end

Given /there are open studios artists with art in the system/ do
  steps %(
    Given there are artists with art in the system
    Given there are future open studios events
  )
  @artists.each do |a|
    a.open_studios_events << OpenStudiosEventService.current
    a.artist_info.update(lat: 37.75, lng: -122.41)
    a.studio&.update(lat: 37.75, lng: -122.41)
  end
end

And /participating artists have filled out their open studios info form/ do
  @artists.each do |a|
    next unless a.current_open_studios_participant

    participant = a.current_open_studios_participant
    schedule = participant.open_studios_event.special_event_time_slots.index_with do |_timeslot|
      true
    end
    participant.update({
                         video_conference_schedule: schedule,
                         show_email: true,
                         show_phone_number: true,
                         shop_url: 'http://myshop.com',
                         youtube_url: 'http://m.youtube.com/watch?v=abcdefg',
                       })
  end
end

Given /there is open studios cms content( in the system)?$/ do |_|
  args = { page: :main_openstudios, section: :preview_reception }
  @os_reception_content ||= CmsDocument.where(args).first || FactoryBot.create(:cms_document, args)

  args = { page: :main_openstudios, section: :summary }
  @os_summary_content ||= CmsDocument.where(args).first || FactoryBot.create(:cms_document, args)
end

Given /there is open studios catalog cms content( in the system)?$/ do |_|
  args = { page: :catalog_open_studios, section: :preview_reception, article: 'This is about the catalog preview' }
  @catalog_content ||= CmsDocument.where(args).first || FactoryBot.create(:cms_document, args)

  args = { page: :catalog_open_studios, section: :summary, article: '## this is going to rock (catalog summary)' }
  @os_summary_content ||= CmsDocument.where(args).first || FactoryBot.create(:cms_document, args)
end

Given /there are users in the system/ do
  @users = FactoryBot.create_list(:fan, 4)
end

Given /there are tags on the art/ do
  @art_piece_tags = FactoryBot.create_list(:art_piece_tag, 10)
  @art_pieces.each_with_index do |art, idx|
    art.tags = @art_piece_tags[0..(idx % 10)]
    art.created_at = art.created_at - idx.days
    art.updated_at = art.updated_at - idx.days
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
    rescue StandardError => e
      Rails.logger.debug { "Failed to create #{mailing_list} : #{e}" }
    end
    clz.first.emails.create(name: Faker::Name.name, email: Faker::Internet.email)
  end
end

Given('there is an active notification') do
  @active_notification ||= FactoryBot.create(:notification, :active)
end
