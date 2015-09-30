require 'pp'
require 'open-uri'
namespace :debug do

  desc 'test json endpoints'
  task test_json_endpoints: [:environment] do
    host = Rails.application.config.action_mailer.default_url_options[:host] || 'localhost:3000'
    dir = File.join(Rails.root, 'tmp/recorded_json_endpoints')
    FileUtils.mkdir_p dir unless Dir.exists?(dir)
    endpoints = %w|/art_piece_tags.json /art_piece_tags/autosuggest /art_pieces.json /art_pieces/1.json  /artists.json /artists/1.json /artists/suggest /events.json /search.json?keywords=a /studios.json /studio/1.json  /api/media /api/media/1 /api/artists /api/artists/1|
    endpoints.each do |endpoint|
      begin
        fname = endpoint.gsub(/[[:punct:]]/, '_').gsub /^_/, ''
        url = File.join("http://#{host}", "#{endpoint}?format=json")
        full_name = File.join( dir, "#{fname}.json")
        url = URI( url )
        puts "Pulling #{url} to #{full_name}"
        fp = File.open(full_name, 'w')
        fp.write(JSON.pretty_unparse(JSON.parse(open(url).read)))
        fp.close
      rescue JSON::ParserError => jpe
        puts "Failed to parse #{url}"
      rescue OpenURI::HTTPError => oe
        puts "Failed to fetch #{url}: #{oe}"
      end
    end
  end

  desc 'create open studios event'
  task create_os_event: [:environment] do
    os = OpenStudiosEvent.current
    unless os && (os.start_date > Time.now)
      start_date = Time.now + 2.months
      end_date = start_date + 2.days
      key = start_date.strftime("%Y%m")
      placeholder_logo = File.join(Rails.root, '/app/assets/images/debug_os_placeholder.png')
      OpenStudiosEvent.create!(start_date: start_date, end_date: end_date, key: key, logo: File.open(placeholder_logo))
      puts "Created new OpenStudiosEvent: #{key}"
    else
      puts "Current OpenStudiosEvent exists: #{os.key}"
    end
  end

  desc 'randomly add 25% of active artists to current open studios'
  task add_os_participants: [:environment, :create_os_event] do
    # make sure there is a current open studios
    puts "Before : #{Artist.open_studios_participants.count} participants"
    os = OpenStudiosEvent.current
    user_ids = Artist.active.select(:id)
    num_users = user_ids.count
    Artist.includes(:artist_info).where(id: user_ids.sample(num_users/4)).each do |a|
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

    pp landscape_ratios.inject(&:+)/landscape_ratios.length.to_f if landscape_ratios.present?
    pp portrait_ratios.inject(&:+)/portrait_ratios.length.to_f if portrait_ratios.present?

  end
end
