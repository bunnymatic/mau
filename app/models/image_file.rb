require 'pathname'

class ImageFile

  include ImageFileHelpers

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

  ALLOWED_IMAGE_EXTS = ["jpg", "jpeg" ,"gif","png" ]

  attr_reader :upload, :destdir, :destfile

  def initialize(upload, destdir, destfile=nil)
    @upload = upload
    @destdir = destdir
    @destfile = (destfile || create_timestamped_filename(uploaded_filename))
  end

  def datafile
    @datafile ||= upload['datafile']
  end

  def uploaded_filename
    @uploaded_filename ||= datafile.original_filename
  end

  def sizes
    @sizes ||= ImageSizes.all
  end

  def self.get_path(dir, size, fname)
    return '' if fname.empty?
    prefix = ImageSizes.prefix(size)
    idx = fname.hash % @@IMG_SERVERS.length
    svr = @@IMG_SERVERS[idx]
    svr + File.join(dir, prefix+fname)
  end

  def save
    ext = get_file_extension(uploaded_filename)
    if ALLOWED_IMAGE_EXTS.index(ext.downcase) == nil
      Rails::logger.error("ImageFile: bad filetype\n")
      raise ArgumentError, "File type doesn't appear to be JPEG, GIF or PNG."
    end

    image_info = save_uploaded_file

    save_resized_versions(image_info)

  end

  def image_paths(image_info)
    file_match = Regexp.new(destfile + "$")
    Hash[ [:large, :medium, :small, :thumb].map do |sz|
            [sz, image_info.path.gsub(file_match, ImageSizes.prefix(sz) + destfile)]
          end ]
  end

  def save_resized_versions(image_info)
    # store resized versions:
    #[:cropped_thumb , srcpath.gsub(file_match, "ct_"+destfile)],
    image_paths(image_info).each do |key, destpath|
      begin
        MojoMagick::resize(image_info.path, destpath,
                           { :width => ImageSizes.width(key),
                             :height => ImageSizes.height(key),
                             :shrink_only => true })
        Rails::logger.debug("ImageFile: wrote %s" % destpath)
      rescue Exception => ex
        Rails::logger.error("ImageFile: ERROR : %s\n" % $!)
        puts ex.backtrace unless Rails.env == 'production'
      end
    end
    image_info
  end

  def write_temp_file
    path = create_dest_dir

    # store the image
    File.open(path, "wb") { |f| f.write(datafile.read) }
    Pathname.new(path).realpath.to_s()
  end

  def save_uploaded_file
    src_path = write_temp_file

    type, height, width, colorspace = check_file_format(src_path)

    ImageInfo.new(:path => src_path, :height => height, :width => width,
                  :colorspace => colorspace, :type => type)
  end

  def check_file_format(src_path)
     # check format
    fmt = MojoMagick::raw_command('identify','-format "%m %h %w %r" ' + src_path)
    (type, height, width, colorspace) = fmt.split
    if ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise ArgumentError, "Image type %s is not supported." % type
    end
    if colorspace.downcase.match /cmyk/
      raise ArgumentError, "[%s] is not a supported color space."+
        "  Please save your image with an RGB colorspace." % colorspace.to_s
    end
    [type, height, width, colorspace]
  end

  def create_dest_dir
    path = File.join(destdir, File.basename(destfile))
    if !File.exists?(destdir)
      result = FileUtils.mkdir_p(destdir)
    end
    path
  end

end
