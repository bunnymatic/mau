class FavoritesController < ApplicationController

  before_filter :login_required

  layout 'mau1col', :except => 'faq'
  
  def index
    @style = nil
    if params[:style]
      @style = params[:style]
    end
  end
end
