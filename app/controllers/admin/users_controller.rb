module Admin
  class UsersController < ::BaseAdminController
    before_filter :set_user, only: [ :show ]

    def show
      puts @user
      @user = ArtistPresenter.new(@user)
      puts @user
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
