module Admin
  class RolesController < ::BaseAdminController
    before_action :admin_required
    before_action :load_role, only: [:show, :edit, :update, :destroy]

    def index
      @roles = Role.all
      @users_by_role = @roles.inject({}) do |memo, role|
        memo[role.role] = role.users.active
        memo
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
      @role_users = @role.users.active
      @users = (User.active.all - @role_users).sort_by{|u| u.full_name.downcase}
      render :edit
    end

    def update
      u = User.find(params[:user])
      begin
        u.roles << @role
        flash[:notice] = "Added #{u.full_name} to role #{@role.role}"
      rescue ActiveRecord::RecordInvalid
        flash[:notice] = "Looks like #{u.full_name} is already in that role."
      end
      redirect_to admin_role_path(@role)
    end

    def destroy
      @role.destroy
      flash[:notice] = "Removed #{@role.role} role"
      redirect_to admin_roles_path
    end

    private
    def load_role
      @role = Role.find(params[:id])
    end

    def role_params
      params.require(:role).permit(:role)
    end
  end
end
