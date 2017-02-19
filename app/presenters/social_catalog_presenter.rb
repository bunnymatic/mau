require 'csv'

class SocialCatalogPresenter < ViewPresenter

  include OpenStudiosEventShim

  SOCIAL_KEYS = User.stored_attributes[:links].reject { |k| k == :website }

  def artists
    @artists ||= Artist.active.open_studios_participants.select do |a|
      SOCIAL_KEYS.map{|s| a.send(s).present?}.any?
    end.sort(&Artist::SORT_BY_LASTNAME)
  end

  def csv
    @csv ||=
      begin
        csv_data = CSV.generate(DEFAULT_CSV_OPTS) do |_csv|
          _csv << csv_headers
          artists.each do |artist|
           _csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def csv_filename
    @csv_filename ||= (['mau_social_artists', current_open_studios_key].compact.join("_") + ".csv")
  end

  private
  def csv_keys
    @csv_keys ||= (base_keys + SOCIAL_KEYS)
  end

  def base_keys
    @base_keys ||= [:full_name, :email]
  end

  def csv_headers
    @csv_headers ||= (csv_keys).map{|s| s.to_s.humanize.capitalize} +
                     ["Art Piece", "Studio Affiliation", "Studio Address", "MAU Link" ]
  end

  def artist_as_csv_row(artist)
    csv_keys.map{|s| (artist.respond_to?(s) && artist.send(s)).to_s} +
      [ representative_piece(artist), artist.studio.try(:name), artist.studio.try(:address), artist_url(artist) ]
  end

  def representative_piece(artist)
    ap = artist.representative_piece
    ap.try(:photo).try(:url, :original)
  end

end
