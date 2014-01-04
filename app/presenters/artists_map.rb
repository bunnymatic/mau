class ArtistsMap < ArtistsPresenter

  include ArtistsHelper

  def with_addresses
    @addresses ||= grouped_by_address.values.flatten.compact
  end

  def grouped_by_address_and_sorted
    @sorted ||= grouped_by_address.sort_by{|k,v| -v.count}
  end

  def grouped_by_address
    @grouped_by_address ||=
      begin
        {}.tap do |keyed|
          artists.each do |a|
            ky = address_key(a)
            (keyed[ky] ||= []) << a if ky
          end
      end
    end
  end

  def artist_path(artist)
    @view_context.artist_path(artist)
  end

  def address_key(artist)
    if artist.has_address?
      address = artist.address_hash
      "%s" % address[:simple]
    end
  end

  def map_data
    Gmaps4rails.build_markers(with_addresses) do |artist, marker|
      address = artist.address_hash
      marker.lat address[:latlng][0]
      marker.lng address[:latlng][1]
      marker.infowindow get_map_info(artist)
    end
  end

end



