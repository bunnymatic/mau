module OpenStudiosSubdomain
  class ArtistsController < BaseOpenStudiosController
    def show
      (redirect_to '/error' and return) unless FeatureFlags.virtual_open_studios?

      artist = Artist.active.joins(:open_studios_events).friendly.find(params[:id])
      @artist = ArtistPresenter.new(artist) if artist&.doing_open_studios?
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "It doesn't look like that artist is doing open studios" unless artist
      redirect_to open_studios_path
    end
  end
end
