class AdminController < ApplicationController
  before_filter :admin_required
  def index
    render :text => "Nothing to see here.  Please move along."
  end
  
  def email_artists
    render :text => 'build this out'
  end
end
