# frozen_string_literal: true
class ArtistsMap < ArtistsPresenter
  def with_addresses
    @addresses ||= grouped_by_address.values.flatten.compact
  end

  def grouped_by_address_and_sorted
    @sorted ||= grouped_by_address.sort_by { |_k, v| -v.count }
  end

  def grouped_by_address
    @grouped_by_address ||=
      begin
      {}.tap do |keyed|
        artists_only_in_the_mission.each do |a|
          ky = address_key(a)
          (keyed[ky] ||= []) << a if ky
        end
      end.select { |_k, v| v.present? }
    end
  end

  def address_key(artist)
    artist.address.to_s if artist.address.present?
  end

  def bounds
    MissionBoundaries::BOUNDS.values.map { |bound| Hash[[:lat, :lng].zip(bound)] }.to_json
  end

  def map_data
    @map_data ||= Gmaps4rails.build_markers(with_addresses) do |artist, marker|
      addr = artist.address
      marker.lat addr.lat
      marker.lng addr.lng
      marker.infowindow artist.get_map_info.html_safe
      marker.hash[:artist_id] = artist.id
    end.to_json
  end
end
