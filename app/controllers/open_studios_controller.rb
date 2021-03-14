class OpenStudiosController < ApplicationController
  def index
    @page_title = PageInfoService.title('Open Studios')
    @presenter = OpenStudiosPresenter.new(current_user)
  end

  def register
    if current_user
      redirect_to register_for_current_open_studios_artists_path
    else
      store_location(register_for_current_open_studios_artists_path)
      redirect_to sign_in_path
    end
  end
end
