# frozen_string_literal: true
class RolesController < ::BaseAdminController
  def destroy
    if params[:id] && params[:user_id]
      remove_role_from_user params[:id], params[:user_id]
    end
    redirect_to admin_role_path(params[:id])
  end

  private

  def remove_role_from_user(role_id, user_id)
    # remove role from user
    begin
      r = Role.find(role_id)
      u = User.find(user_id)
      if u && r
        u.roles_users.select{|ru| ru.role_id == r.id}.map(&:destroy)
        flash[:notice] = "Removed #{r.role} role from #{u.full_name}"
      end
    rescue ActiveRecord::RecordNotFound => ex
      flash[:error] = "Unable to find the role or user.  Nothing done."
    end
  end
end
