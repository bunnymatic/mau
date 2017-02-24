class CatalogsController < ApplicationController

  layout 'catalog'

  def show
    @catalog = CatalogPresenter.new

    respond_to do |format|
      format.html # index.html.erb
      format.csv {
        render_csv_string(@catalog.csv, @catalog.csv_filename)
      }
    end
  end

  def social
    respond_to do |format|
      @social_artists = SocialCatalogPresenter.new
      format.html
      format.csv {
        render_csv_string(@social_artists.csv, @social_artists.csv_filename)
      }
    end
  end

end
