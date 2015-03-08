class ArtistsRoster < ArtistsPresenter
  def initialize(vc, os)
    @view_context = vc
    super os
  end

end
