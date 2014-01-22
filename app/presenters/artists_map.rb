class ArtistsMap < ArtistsPresenter

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

  def address_key(artist)
    if artist.has_address?
      addr = artist.artist.address_hash
      "%s" % addr[:simple]
    end
  end

  def map_data
    Gmaps4rails.build_markers(with_addresses) do |artist, marker|
      addr = artist.artist.address_hash
      marker.lat addr[:latlng][0]
      marker.lng addr[:latlng][1]
      marker.infowindow artist.get_map_info.html_safe
    end.to_json
  end

end



