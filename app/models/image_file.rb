require 'pathname'

class ImageFile

  class ImageSizes
    class ImageSize < Struct.new(:width, :height, :prefix); end
    @@sizes = {
      :thumb => ImageSize.new(100, 100, 't_'),
      :cropped_thumb => ImageSize.new( 127, 127, 'ct_'),
      :small => ImageSize.new( 200, 200, 's_'),
      :std => ImageSize.new( 400, 400, 'm_'), 
      :large => ImageSize.new( 800, 800, 'l_')
    }.freeze

    def self.all
      @@sizes
    end

    def self.prefix(sz)
      k = keymap(sz)
      (@@sizes.include? k) ? @@sizes[keymap(sz)].prefix : 'm_'
    end

    def self.width(sz)
      k = keymap(sz)
      (@@sizes.include? k) ? @@sizes[keymap(sz)].width : 0
    end

    def self.height(sz)
      k = keymap(sz)
      (@@sizes.include? k) ? @@sizes[keymap(sz)].height : 0
    end


    def self.keymap(sz) 
      case sz.to_s
      when "orig"
        :original
      when "sm", "s"
        :small
      when 'thumbnail'
        :thumb
      when 'medium','med', 'm', 'standard'
        :std
      else
        sz.to_sym
      end
    end

  end
  
  @@IMG_SERVERS = ['']
  @@FILENAME_CLEANER = '/[\#|\*|\(|\)|\[|\]|\{|\}|\&|\<|\>|\$|\!\?|\;|\'/'
  if Conf.image_servers
    Conf.image_servers.each do |svr|
      @@IMG_SERVERS << svr
    end
    RAILS_DEFAULT_LOGGER.info("IMAGE SERVERS [%s]" % @@IMG_SERVERS)
  end

  @@ALLOWED_IMAGE_EXTS = ["jpg", "jpeg" ,"gif","png" ]
 
  def self.sizes
    ImageSizes.all
  end

  def self.get_path(dir, size, fname)
    if not fname or fname.length < 1
      return ''
    end
    prefix = ImageSizes.prefix(size)
    idx = fname.hash % @@IMG_SERVERS.length
    svr = @@IMG_SERVERS[idx]
    svr + File.join(dir, prefix+fname)
  end

  def self.save(upload, destdir, destfile=nil)
    logger = RAILS_DEFAULT_LOGGER
    dot_pos = upload.original_filename.rindex(".")
    if not dot_pos
      logger.error("ImageFile: no file extension\n") 
      raise ArgumentError, "Cannot determine file type without an extension."
    end
    dot_pos += 1
    ext = upload.original_filename[dot_pos..-1]
    if @@ALLOWED_IMAGE_EXTS.index(ext.downcase) == nil
      logger.error("ImageFile: bad filetype\n") 
      raise ArgumentError, "File type doesn't appear to be JPEG, GIF or PNG."
    end
    ts = Time.now.to_i
    destfile = ts.to_s + File.basename(upload.original_filename) if !destfile
    # make filename something nice
    destfile.gsub!(@@FILENAME_CLEANER,'')
    destfile.gsub!(/ /,'')
    dir = destdir
    path = File.join(dir, File.basename(destfile))
    if !File.exists?(dir)
      result = FileUtils.mkdir_p(dir) 
      logger.debug("ImageFile: created %s (%0.2f sec)\n" % [ result, Time.now.to_f - ts ])
    end

    # store the image
    result = File.open(path, "wb") { |f| f.write(upload.read) }
    srcpath = Pathname.new(path).realpath.to_s()
    logger.info("ImageFile: wrote file %s (%0.2f sec)\n" % [ srcpath, Time.now.to_f - ts ])

     # check format
    fmt = MojoMagick::raw_command('identify','-format "%m %h %w %r" ' + srcpath)
    (type, height, width, colorspace) = fmt.split
    if @@ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise ArgumentError, "Image type %s is not supported." % type
    end
    if colorspace.downcase.match /cmyk/
      raise ArgumentError, "[%s] is not a supported color space.  Please save your image with an RGB colorspace." % colorspace.to_s
    end
    height = height.to_i
    width = width.to_i

    # store resized versions:
    file_match = Regexp.new(destfile + "$")
    #[:cropped_thumb , srcpath.gsub(file_match, "ct_"+destfile)],
    paths = [:large, :std, :small, :thumb].map do |sz|
      [sz, srcpath.gsub(file_match, ImageSizes.prefix(sz) + destfile)]
    end
    p paths
    paths.each do |pthinfo|
      key = pthinfo[0]
      destpath = pthinfo[1]
      begin
        MojoMagick::resize(srcpath, destpath,
                           { :width => ImageSizes.width(key),
                             :height => ImageSizes.height(key),
                             :shrink_only => true })
        logger.debug("ImageFile: wrote %s" % destpath)
      rescue Exception => ex
        logger.error("ImageFile: ERROR : %s\n" % $!)
        puts ex.backtrace unless Rails.env == 'production'
      end
    end
    logger.info("Image conversion took %0.2f sec" % (Time.now.to_f - ts) )
    [ path, height, width ]
  end
end
