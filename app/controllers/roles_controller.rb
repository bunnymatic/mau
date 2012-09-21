class RolesController < ApplicationController
  layout "mau-admin"
  before_filter :admin_required
  def index
    @roles = Role.all
    users = RolesUser.all
    @users_by_role = @roles.inject({}) do |r, role|
      r[role.role] = []
      r
    end
    users.each do |u|
      @users_by_role[u.role.role] << u.user if u.user.active?
    end
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

  def edit
    @role = Role.find(params[:id])
    @users = RolesUser.find_all_by_role_id(@role.id).map(&:user)
  end
  
  def destroy
    r = Role.find_all_by_id(params[:id])
    if r && !r.empty?
      r.first.destroy
    end
    redirect_to roles_path
  end

end
