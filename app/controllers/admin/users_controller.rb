# frozen_string_literal: true
module Admin
  class UsersController < ::BaseAdminController
    before_action :set_user, only: [ :show ]

    def show
      @user = ArtistPresenter.new(@user)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
