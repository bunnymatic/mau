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
      @users = User.active.all.reject{|u| @role_users.map(&:id).include? u.id}.sort_by{|u| u.full_name.downcase}
      render :edit
    end

    def update
      if params[:id] && params[:user]
        u = User.find(params[:user])
        r = Role.find(params[:id])
        begin
          u.roles << r
          u.save
          flash[:notice] = "Added #{u.full_name} to role #{r.role}"
        rescue ActiveRecord::RecordInvalid
          flash[:notice] = "Looks like #{u.full_name} is already in that role."
        end
      end
      redirect_to admin_role_path(params[:id])
    end

    def destroy
      r = Role.find(params[:id])
      if r
        name = r.role
        r.destroy
        flash[:notice] = "Removed #{name} role"
      end
      redirect_to admin_roles_path
    end

    private

    def role_params
      params.require(:role).permit(:role)
    end
  end
end
