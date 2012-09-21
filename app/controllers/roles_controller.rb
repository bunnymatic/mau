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
    users = RolesUser.all
    
    @users = User.active
    @users_in_roles = {}
    
    invalid_roles = ['a', 'nil']
    @users.each do |u|
      @roles.compact.reject{|role| invalid_roles.include? role.role}.each do |r|
        k = r.role
        method = "is_#{k}?"
        @users_in_roles[k] = [] if @users_in_roles[k].nil?
        @users_in_roles[k] << u if u.respond_to?(method) && u.send(method)
      end
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
