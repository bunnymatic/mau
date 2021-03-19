class OpenStudiosPromoPresenter < BaseOpenStudiosPresenter
  PAGE = 'main_openstudios'.freeze
  def initialize(current_user)
    super PAGE, current_user
  end
end
