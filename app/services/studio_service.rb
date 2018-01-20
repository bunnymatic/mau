# frozen_string_literal: true

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

  def self.find(id)
    get_studio_from_id id
  end

  class << self
    private

    def get_studio_from_id(id)
      if (id == 'independent-studios') || (id.to_s == '0')
        Studio.indy
      else
        begin
          Studio.friendly.find(id)
        rescue StandardError
          nil
        end
      end
    end
  end
end
