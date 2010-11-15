class FavoritesController < ApplicationController
  before_filter :login_required 
  #before_filter :admin_required, :only => [ :admin_list ]

  def create
    if !logged_in?
      render_not_found Exception.new("Sorry, you must be logged in to create favorites")
      return
    end
    fav = params[:fav]
    if !fav
      flash[:error] = "Unable to add favorite.  Invalid input parameters"
      redirect_back_or_default(user_path(current_user))
      return
    end
    if fav[:id] == current_user.id
      flash[:error] = "You can't favorite yourself or your own work, even if you are your biggest fan."
    else
      new_favorite = Favorite.new(:obj_id => fav[:id], 
                                  :obj_type => fav[:object],
                                  :user_id => current_user.id)
      valid = new_favorite && new_favorite.valid?
      errs = new_favorite.errors
    end
    if valid && errs.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      flash[:notice] = "You just added a favorite!"
      new_favorite.save!
    end
    redirect_back_or_default(user_path(current_user))
  end

end
