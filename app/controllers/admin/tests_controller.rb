# frozen_string_literal: true
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

    def markdown; end

    def social_icons; end

    def flash_test
      flash.now[:notice] = 'The current time is %s' % Time.zone.now
      flash.now[:error] = 'This is an error at %s' % Time.zone.now
    end

    def qr
      render && return unless request.post?

      @string_to_encode = params['string_to_encode']
      @pixel_size = params['pixel_size']
      if @string_to_encode.present?
        opts = {}
        ['pixel_size'].each do |opt|
          opts[opt.to_sym] = params[opt] if params[opt]
        end
        base_file = File.join('images', 'tmp', "qrtest_#{Time.zone.now.to_i}.png")
        f = Rails.root.join('public', base_file)
        FileUtils.mkdir_p(File.dirname(f))
        Qr4r.encode(params['string_to_encode'], f.to_s, opts)
        @qrfile = '/' + base_file
      end
    end
  end
end
