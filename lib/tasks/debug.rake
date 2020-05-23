# frozen_string_literal: true

require 'pp'
require 'open-uri'
namespace :debug do
  desc 'create open studios event'
  task create_os_event: [:environment] do
    os = OpenStudiosEvent.current
    if os && (os.start_date > Time.current)
      puts "Current OpenStudiosEvent exists: #{os.key}"
    else
      start_date = Time.current + 2.months
      end_date = start_date + 2.days
      key = start_date.strftime('%Y%m')
      placeholder_logo = Rails.root.join('app', 'assets', 'images', 'debug_os_placeholder.png')
      OpenStudiosEvent.create!(start_date: start_date, end_date: end_date, key: key, logo: File.open(placeholder_logo))
      puts "Created new OpenStudiosEvent: #{key}"
    end
  end

  desc 'randomly add 25% of active artists to current open studios'
  task add_os_participants: %i[environment create_os_event] do
    # make sure there is a current open studios
    puts "Before : #{Artist.open_studios_participants.count} participants"
    os = OpenStudiosEvent.current
    user_ids = Artist.active.select(:id)
    num_users = user_ids.count
    Artist.includes(:artist_info).where(id: user_ids.sample(num_users / 4)).each do |a|
      a.update_os_participation os.key, true
    end
    puts "After : #{Artist.open_studios_participants.count} participants"
  end

  desc 'compute average aspect ratio'
  task average_aspect_ratio: [:environment] do
    landscape = []
    portrait = []
    ArtPiece.find_each do |art_piece|
      if art_piece.artist.try(:active?)
        if art_piece.portrait?
          portrait << art_piece
        else
          landscape << art_piece
        end
      end
    end

    landscape_ratios = landscape.map(&:aspect_ratio).compact
    portrait_ratios = portrait.map(&:aspect_ratio).compact

    pp landscape_ratios.inject(&:+) / landscape_ratios.length.to_f if landscape_ratios.present?
    pp portrait_ratios.inject(&:+) / portrait_ratios.length.to_f if portrait_ratios.present?
  end
end
