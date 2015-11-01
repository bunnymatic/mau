# Serve as a studio finder service
#
# this should help normalize and compartmentalize all the places
# where we try to identify or use the Independent Studio
# (until it's refactored so we don't have to play these tricks)
class StudioService

  MIN_ARTISTS_PER_STUDIO = (Conf.min_artists_per_studio || 3)

  def self.all
    Studio.by_position.all
  end

  def self.all_studios
    all.select { |s| s.artists.active.count >= MIN_ARTISTS_PER_STUDIO }
  end

  def self.get_studio_from_id(_id)
    if (_id == 'independent-studios') || (_id.to_s == '0')
      return Studio.indy()
    else
      begin
        Studio.find(_id)
      rescue
        nil
      end
    end
  end

end
