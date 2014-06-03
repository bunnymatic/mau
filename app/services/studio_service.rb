# Serve as a studio finder service
#
# this should help normalize and compartmentalize all the places
# where we try to identify or use the Independent Studio
# (until it's refactored so we don't have to play these tricks)
class StudioService

  MIN_ARTISTS_PER_STUDIO = (Conf.min_artists_per_studio || 3)

  def self.all_studios
    Studio.all.select do |s|
      if s.id != 0 && s.name == 'Independent Studios'
        false
      else
        s.artists.active.count >= MIN_ARTISTS_PER_STUDIO
      end
    end
  end

  def self.studio_keys
    Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s]}]
  end

  def self.get_studio_from_id(_id)
    if (_id == 'independent_studios') || (_id.to_s == '0')
      studio = Studio.indy()
    else
      studio = studio_keys[_id] || Studio.where(:id => _id).first
    end
  end

end

