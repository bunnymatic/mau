require 'find'
require 'ftools'
namespace :mau do
  desc "Send twitter updates about artists who've updated their art today"
  task :tweetart => [:environment] do
    aps = ArtPiece.get_todays_art
    if aps.length 
      artists = Artist.active.find_all_by_id( aps.map{ |ap| ap.artist_id })
      p artists
    end
  end
end
