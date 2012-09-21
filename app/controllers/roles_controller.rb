class RolesController < ApplicationController
  layout "mau-admin"
  before_filter :admin_required
  def index
    @roles = Role.all
  end
  
  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      redirect_to roles_path and return
    else
      render :new
    end
  end

  def destroy
    r = Role.find_all_by_id(params[:id])
    if r && !r.empty?
      r.first.destroy
    end
    redirect_to roles_path
  end

end
