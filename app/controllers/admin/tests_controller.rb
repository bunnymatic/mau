require 'qr4r'
require 'tempfile'

module Admin
  class TestsController < ::BaseAdminController
    # GET /studios
    # GET /studios.xml
    before_action :admin_required

    def show; end

    def map
      @map_info = ArtistsMap.new
      @artists = @map_info.with_addresses
    end

    def social_icons; end

    def flash_test
      flash.now[:notice] = sprintf('The current time is %s', Time.zone.now)
      flash.now[:error] = sprintf('This is an error at %s', Time.zone.now)
    end

    def qr
      render && return unless request.post?

      @string_to_encode = params['string_to_encode']
      @pixel_size = params['pixel_size']

      if @string_to_encode.blank?
        flash[:error] = 'How about you give me some words to work on?'
        render && return
      end

      opts = {}
      ['pixel_size'].each do |opt|
        opts[opt.to_sym] = params[opt] if params[opt]
      end
      base_file = File.join('images', 'tmp', "qrtest_#{Time.zone.now.to_i}.png")
      f = Rails.root.join("public/#{base_file}")
      FileUtils.mkdir_p(File.dirname(f))
      Qr4r.encode(params['string_to_encode'], f.to_s, opts)
      @qrfile = "/#{base_file}"
    end

    def react_styleguide; end
  end
end
