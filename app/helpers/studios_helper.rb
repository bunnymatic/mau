require "rand_helpers"
module StudiosHelper
  def self.get_random_artists_work(studioid, num)
    artists = []
    all = Artist.where(:studio_id => studioid)
    numpieces = all.length
    if numpieces > num
      artists = choice(all, num)
    else
      artists = all
    end
    artists.map { |a| a.representative_piece if a.representative_piece }
  end
end
