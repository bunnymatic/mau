# frozen_string_literal: true

class ArtistsMap < ArtistsPresenter
  def with_addresses
    @with_addresses ||= grouped_by_address.values.flatten.compact
  end

  def grouped_by_address_and_sorted
    @grouped_by_address_and_sorted ||= grouped_by_address.sort_by { |_k, v| -v.count }
  end

  def grouped_by_address
    @grouped_by_address ||=
      begin
        by_address = {}.tap do |keyed|
          artists.select(&:in_the_mission?).each do |a|
            ky = address_key(a)
            (keyed[ky] ||= []) << a if ky
          end
        end
        by_address.select { |_k, v| v.present? }
      end
  end

  def address_key(artist)
    artist.address.to_s if artist.address.present?
  end

  def bounds
    MissionBoundaries::BOUNDS.values.map { |bound| Hash[%i[lat lng].zip(bound)] }.to_json
  end

  def map_marker(artist)
    {
      lat: artist.lat,
      lng: artist.lng,
      infowindow: artist.map_info,
      artist_id: artist.id,
    }
  end

  def map_data
    @map_data ||= with_addresses.map { |a| map_marker(a) }.to_json
  end
end
