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
    if params[:id] && params[:user_id] 
      remove_role_from_user params[:id], params[:user_id]
    else
      r = Role.find_all_by_id(params[:id])
      if r && !r.empty?
        r.first.destroy
      end
    end
    redirect_to roles_path
  end

  private
  def remove_role_from_user role_id, user_id
    # remove role from user
    begin
      r = Role.find(role_id)
      u = User.find(user_id)
      if u && r
        u.roles_users.select{|ru| ru.role_id == r.id}.map(&:destroy)
        flash[:notice] = "Removed #{r.role} role from #{u.fullname}"
      end
    rescue ActiveRecord::RecordNotFound => ex
      flash[:error] = "Unable to find the role or user.  Nothing done."
    end
  end

end
