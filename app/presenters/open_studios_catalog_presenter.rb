class OpenStudiosCatalogPresenter < BaseOpenStudiosPresenter
  PAGE = 'catalog_open_studios'.freeze
  def initialize(current_user)
    super PAGE, current_user
  end
end
