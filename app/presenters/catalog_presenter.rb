require 'csv'

class CatalogPresenter

  include MarkdownUtils

  def csv_filename
    @csv_filename ||= (['mau_catalog', Conf.oslive.to_s].compact.join("_") + '.csv')
  end

  def csv
    @csv ||=
      begin
        CSV.generate(ApplicationController::DEFAULT_CSV_OPTS) do |_csv|
          _csv << csv_headers
          all_artists.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            _csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def all_artists
    @all_artists ||= Artist.active.open_studios_participants
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
          artist_list.sort! &Artist::SORT_BY_LASTNAME
        end
        artists
    end
  end

  def preview_reception_data
    Hash[preview_receptions.except(:content).map{|k,v| ["data-#{k}", v]}]
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
    @csv_headers ||= ["First Name","Last Name","Full Name","Email", "Group Site Name",
                      "Studio Address","Studio Number","Cross Street 1","Cross Street 2","Primary Medium"]
  end
  
  def artist_as_csv_row(artist)
    [
     artist.csv_safe(:firstname),
     artist.csv_safe(:lastname),
     artist.get_name(true),
     artist.email,
     artist.studio ? artist.studio.name : '', 
     artist.address_hash[:parsed][:street],
     artist.studionumber, 
     '', 
     '', 
     artist.primary_medium ? artist.primary_medium.name : '' 
    ]
  end

end
