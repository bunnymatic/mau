require 'pathname'

class ImageFile

  extend ImageFileHelpers

  class ImageSizes
    class ImageSize < Struct.new(:width, :height, :prefix); end
    @@sizes = {
      :thumb => ImageSize.new(100, 100, 't_'),
      :cropped_thumb => ImageSize.new( 127, 127, 'ct_'),
      :small => ImageSize.new( 200, 200, 's_'),
      :medium => ImageSize.new( 400, 400, 'm_'),
      :large => ImageSize.new( 800, 800, 'l_'),
      :original => ImageSize.new( nil, nil, '')
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
      return :medium if sz.blank?
      allowed_sizes = @@sizes.keys
      return sz.to_sym if (allowed_sizes.include? sz.to_sym)
      case sz.to_s
      when "orig"
        :original
      when "sm", "s"
        :small
      when 'thumbnail'
        :thumb
      when 'med', 'm', 'standard', 'std'
        :medium
      when 'l'
        :large
      else
        :medium
      end
    end

  end

  @@IMG_SERVERS = ['']
  # Currenly not using image_servers
  #
  # if Conf.image_servers
  #   Conf.image_servers.each do |svr|
  #     @@IMG_SERVERS << svr
  #   end
  #   ::Rails.logger.info("IMAGE SERVERS [%s]" % @@IMG_SERVERS)
  # end

  @@ALLOWED_IMAGE_EXTS = ["jpg", "jpeg" ,"gif","png" ]

  def self.logger
    ::Rails.logger
  end

  def self.sizes
    ImageSizes.all
  end

  def self.get_path(dir, size, fname)
    return '' if fname.empty?
    prefix = ImageSizes.prefix(size)
    idx = fname.hash % @@IMG_SERVERS.length
    svr = @@IMG_SERVERS[idx]
    svr + File.join(dir, prefix+fname)
  end

  def self.save(upload, destdir, destfile=nil)
    ts = Time.zone.now.to_f

    ext = get_file_extension(upload.original_filename)
    if @@ALLOWED_IMAGE_EXTS.index(ext.downcase) == nil
      logger.error("ImageFile: bad filetype\n")
      raise ArgumentError, "File type doesn't appear to be JPEG, GIF or PNG."
    end
    destfile ||= create_timestamped_filename(upload.original_filename)

    image_info = save_uploaded_file(upload, destdir, destfile)

    # store resized versions:
    file_match = Regexp.new(destfile + "$")
    #[:cropped_thumb , srcpath.gsub(file_match, "ct_"+destfile)],
    paths = Hash[ [:large, :medium, :small, :thumb].map do |sz|
      [sz, image_info.path.gsub(file_match, ImageSizes.prefix(sz) + destfile)]
    end ]
    paths.each do |key, destpath|
      begin
        MojoMagick::resize(image_info.path, destpath,
                           { :width => ImageSizes.width(key),
                             :height => ImageSizes.height(key),
                             :shrink_only => true })
        logger.debug("ImageFile: wrote %s" % destpath)
      rescue Exception => ex
        logger.error("ImageFile: ERROR : %s\n" % $!)
        puts ex.backtrace unless Rails.env == 'production'
      end
    end
    logger.info("Image conversion took %0.2f sec" % (Time.zone.now.to_f - ts) )
    image_info
  end

  def self.save_uploaded_file(upload, destdir, destfile)
    ts = Time.zone.now.to_f
    path = create_dir(destdir, destfile)

    # store the image
    result = File.open(path, "wb") { |f| f.write(upload.read) }
    srcpath = Pathname.new(path).realpath.to_s()
    logger.info("ImageFile: wrote file %s (%0.2f sec)\n" % [ srcpath, Time.zone.now.to_f - ts ])

     # check format
    fmt = MojoMagick::raw_command('identify','-format "%m %h %w %r" ' + srcpath)
    (type, height, width, colorspace) = fmt.split
    if @@ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise ArgumentError, "Image type %s is not supported." % type
    end
    if colorspace.downcase.match /cmyk/
      raise ArgumentError, "[%s] is not a supported color space."+
        "  Please save your image with an RGB colorspace." % colorspace.to_s
    end

    ImageInfo.new(:path => srcpath, :height => height, :width => width, :colorspace => colorspace, :type => type)
  end

  def self.create_dir(dir, destfile)
    ts = Time.zone.now.to_f
    path = File.join(dir, File.basename(destfile))
    if !File.exists?(dir)
      result = FileUtils.mkdir_p(dir)
      logger.debug("ImageFile: created %s (%0.2f sec)\n" % [ result, Time.zone.now.to_f - ts ])
    end
    path
  end

end
