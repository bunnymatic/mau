# frozen_string_literal: true

class AdminArtistUpdateService
  def self.bulk_update_os(os_status_by_artist_id)
    current_os = OpenStudiosEventService.current

    return [false, { alert: "You must have an Open Studios Event in the future before you can set artists' status." }] if current_os.nil?

    return [false, { notice: 'Nothing to do... Did you mean to tell me who you wanted to update?' }] if os_status_by_artist_id.empty?

    updated_count, skipped_count = run_update(os_status_by_artist_id, current_os)

    msg = "Updated setting for #{updated_count} artists"
    msg += sprintf(' and skipped %d artists who are not in the mission or have an invalid address', skipped_count) if skipped_count.positive?
    [true, { notice: msg }]
  end

  class << self
    private

    def truthy?(value)
      ['on', 'true', true, '1'].include? value
    end

    def run_update(os_updates_by_artist_id, current_os)
      updated_count = 0
      skipped_count = 0

      Artist.active.where(id: os_updates_by_artist_id.keys).each do |artist|
        changed = update_artist_os_standing(
          artist,
          current_os,
          truthy?(os_updates_by_artist_id[artist.id.to_s]),
        )
        if changed.nil?
          skipped_count += 1
        elsif changed
          updated_count += 1
        end
      end
      [updated_count, skipped_count]
    end

    # return ternary - nil if the artist was skipped, else true if the artist setting was changed, false if not
    def update_artist_os_standing(artist, current_os, doing_it)
      return nil if artist.address.blank?
      return false if artist.doing_open_studios? == doing_it

      if doing_it
        OpenStudiosParticipationService.participate(artist, current_os)
      else
        OpenStudiosParticipationService.refrain(artist, current_os)
      end
      true
    end
  end
end
