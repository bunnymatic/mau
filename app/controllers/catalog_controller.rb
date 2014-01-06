class CatalogController < ApplicationController
  include MarkdownUtils
  layout 'catalog'

  def index

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
      format.html { render_error :message => 'Dunno what you were looking for.' }
      format.mobile { redirect_to root_path }
      format.csv {
        @social_artists = SocialCatalogPresenter.new
        render_csv_string(@social_artists.csv, @social_artists.csv_filename)
      }
    end
  end

end
