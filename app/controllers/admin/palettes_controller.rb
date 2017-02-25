# frozen_string_literal: true
module Admin
  class PalettesController < ::BaseAdminController
    def show
      f = File.expand_path('app/assets/stylesheets/_colors.scss')
      @colors = SassColorExtractor::Base.parse_colors(f)
    end
  end
end
