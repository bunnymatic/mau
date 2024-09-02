module Admin
  class UsersController < ::BaseAdminController
    before_action :set_user, only: [:show]

    def show
      @user = ArtistPresenter.new(@user)
      @current_open_studios = OpenStudiosEventPresenter.new(OpenStudiosEventService.current)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
