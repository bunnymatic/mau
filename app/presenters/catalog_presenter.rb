# frozen_string_literal: true
require 'csv'

class CatalogPresenter < ViewPresenter
  include OpenStudiosEventShim

  def csv_filename
    @csv_filename ||= (['mau_catalog', current_open_studios_key].compact.join('_') + '.csv')
  end

  def csv
    @csv ||=
      begin
        CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << csv_headers
          all_artists.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def all_artists
    @all_artists ||= Artist.active.open_studios_participants.includes(:studio, :artist_info)
  end

  def indy_artists
    @indy_artists ||= all_artists.reject(&:in_a_group_studio?)
  end

  def indy_artists_count
    @indy_artists_count ||= indy_artists.length
  end

  def group_studio_artists
    @group_studio_artists ||= all_artists.select(&:in_a_group_studio?)
  end

  def artists_by_studio
    @artists_by_studio ||=
      begin
      artists = {}
      group_studio_artists.each do |a|
        artists[a.studio] = [] unless artists[a.studio]
        artists[a.studio] << a
      end
      artists.values.each do |artist_list|
        artist_list.sort!(&Artist::SORT_BY_LASTNAME)
      end
      artists
    end
  end

  def preview_reception_data
    Hash[preview_receptions.except(:content).map { |k, v| ["data-#{k}", v] }]
  end

  def preview_reception_content
    preview_receptions[:content]
  end

  def preview_receptions
    @preview_receptions ||=
      begin
        page = 'main_openstudios'
        section = 'preview_reception'
        CmsDocument.packaged(page, section)
      end
  end

  private

  def csv_headers
    @csv_headers ||= ['First Name', 'Last Name', 'Full Name', 'Email', 'Group Site Name',
                      'Studio Address', 'Studio Number', 'Cross Street 1', 'Cross Street 2', 'Media']
  end

  def artist_as_csv_row(artist)
    a = ArtistPresenter.new(artist)
    [
      csv_safe(a.firstname),
      csv_safe(a.lastname),
      a.get_name(true),
      a.email,
      a.studio.try(:name).to_s,
      a.address.street,
      a.studionumber,
      a.studio.try(:cross_street).to_s,
      '',
      a.media.map(&:name).join(' ')
    ]
  end
end
