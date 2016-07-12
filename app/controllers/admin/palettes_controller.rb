module Admin
  class PalettesController < AdminController

    def show
      f = File.expand_path('app/assets/stylesheets/_colors.scss')
      @colors = ScssFileReader.new(f).parse_colors
    end

  end
end
