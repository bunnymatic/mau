require 'qr4r'
require 'tempfile'

class TestsController < ApplicationController
  # GET /studios
  # GET /studios.xml
  before_filter :admin_required
  layout 'mau-admin'

  def flash_test
    flash.now[:notice] = 'The current time is %s' % Time.now
    flash.now[:error] = 'This is an error at %s' % Time.now
  end

  def qr
    if request.post?
      @string_to_encode = params["string_to_encode"]
      @pixel_size = params["pixel_size"]
      if @string_to_encode.present?
        opts = {}
        ["pixel_size"].each do |opt|
          if params[opt]
            opts[opt.to_sym] = params[opt]
          end
        end
        base_file = File.join('images', 'tmp', "qrtest_#{Time.now.to_i}.png")
        f = File.join(Rails.root, 'public', base_file)
        FileUtils.mkdir_p( File.dirname(f) )
        p opts
        Qr4r::encode(params["string_to_encode"], f, opts )
        @qrfile = "/" + base_file 
      end
    end
  end

  def calendar_picker
  end

end
