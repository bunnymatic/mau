# frozen_string_literal: true
class CatalogsController < ApplicationController
  layout 'catalog'

  def show
    @catalog = CatalogPresenter.new

    respond_to do |format|
      format.html # index.html.erb
      format.csv do
        render_csv_string(@catalog.csv, @catalog.csv_filename)
      end
    end
  end

  def social
    respond_to do |format|
      @social_artists = SocialCatalogPresenter.new
      format.html
      format.csv do
        render_csv_string(@social_artists.csv, @social_artists.csv_filename)
      end
    end
  end
end
