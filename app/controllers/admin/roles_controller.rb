module Admin
  class RolesController < BaseAdminController
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
      @role = Role.new(role_params)
      if @role.save
        redirect_to admin_roles_path and return
      else
        render :new
      end
    end

    def show
      show_or_edit
    end

    def edit
      show_or_edit
    end

    def show_or_edit
      @role = Role.find(params[:id])
      @role_users = RolesUser.where(:role_id => @role.id).map(&:user)
      @users = User.active.all.reject{|u| @role_users.map(&:id).include? u.id}.sort_by{|u| u.fullname.downcase}
      render :edit
    end

    def update
      if params[:id] && params[:user]
        u = User.find(params[:user])
        r = Role.find(params[:id])
        begin
          u.roles << r
          u.save
          flash[:notice] = "Added #{u.fullname} to role #{r.role}"
        rescue ActiveRecord::RecordInvalid
          flash[:notice] = "Looks like #{u.fullname} is already in that role."
        end
      end
      redirect_to admin_role_path(params[:id])
    end

    def destroy
      if params[:id] && params[:user_id]
        remove_role_from_user params[:id], params[:user_id]
        redirect_to admin_role_path(params[:id])
      else
        r = Role.find(params[:id])
        if r
          name = r.role
          r.destroy
          flash[:notice] = "Removed #{name} role"
        end
        redirect_to admin_roles_path
      end
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

    def role_params
      params.require(:role).permit(:role)
    end
  end
end
