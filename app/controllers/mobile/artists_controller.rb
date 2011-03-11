class Mobile::ArtistsController < ApplicationController
  layout 'mobile'
  
  def index
    @artists = []
    if Artist.column_names.include? params[:sortby]
      @artists = Artist.active.find(:all, :order => params[:sortby])
    end
  end

  def show
    if params[:id].blank?
      redirect_to mobile_studios
    end

    begin
      use_id = Integer(params[:id])
    rescue ArgumentError
      use_id = false
    end
    begin
      if !use_id 
        @artist = Artist.active.find_by_login(params[:id])
      else
        @artist = Artist.active.find(params[:id])
      end
    rescue ActiveRecord::RecordNotFound
    end
  end
end
