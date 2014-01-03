class CatalogPresenter

  include MarkdownUtils

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

end
