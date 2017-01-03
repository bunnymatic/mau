module Admin
  class PalettesController < ::BaseAdminController

    def show
      f = File.expand_path('app/assets/stylesheets/_colors.scss')
      @colors = ScssColorReader.new(f).parse_colors
    end

  end
end
