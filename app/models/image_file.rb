require 'pathname'

class ImageFile

  include ImageFileHelpers

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

  def datafile
    @datafile ||= upload['datafile']
  end

  def uploaded_filename
    @uploaded_filename ||= datafile.original_filename
  end

  def sizes
    @sizes ||= MauImage::ImageSize.all
  end

  def self.get_path(dir, size, fname)
    return '' if fname.empty?
    prefix = MauImage::ImageSize.find(size).prefix
    idx = fname.hash % @@IMG_SERVERS.length
    svr = @@IMG_SERVERS[idx]
    svr + File.join(dir, prefix+fname)
  end

  # def save(upload, destdir, destfile=nil)
  #   @upload = upload
  #   @destdir = destdir
  #   @destfile = (destfile || create_timestamped_filename(uploaded_filename))

  #   ext = get_file_extension(uploaded_filename)
  #   if ALLOWED_IMAGE_EXTS.index(ext.downcase) == nil
  #     Rails::logger.error("ImageFile: bad filetype\n")
  #     raise MauImage::ImageError.new("File type doesn't appear to be JPEG, GIF or PNG.")
  #   end

  #   image_info = save_uploaded_file

  #   save_resized_versions(image_info)
  # end

  def image_paths(image_info)
    file_match = Regexp.new(destfile + "$")
    Hash[ [:large, :medium, :small, :thumb].map do |sz|
            [sz, image_info.path.gsub(file_match, MauImage::ImageSize.find(sz).prefix + destfile)]
          end ]
  end

  def save_resized_versions(image_info)
    # store resized versions:
    #[:cropped_thumb , srcpath.gsub(file_match, "ct_"+destfile)],
    image_paths(image_info).each do |key, destpath|
      begin
        MojoMagick::resize(image_info.path, destpath,
                           { :width => MauImage::ImageSize.find(key).width,
                             :height => MauImage::ImageSize.find(key).height,
                             :shrink_only => true })
        Rails::logger.debug("ImageFile: wrote %s" % destpath)
      rescue Exception => ex
        msg = "ImageFile: ERROR : %s\n" % $!
        Rails.logger.error msg
        raise MauImage::ImageError.new(msg)
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
    fmt = MojoMagick::get_format(src_path, %q[%m %h %w %r])
    (type, height, width, colorspace) = fmt.split
    if ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise MauImage::ImageError.new("Image type %s is not supported." % type)
    end
    if colorspace.downcase.match /cmyk/
      raise MauImage::ImageError.new("[#{colorspace}] is not a supported color space."+
                                     "  Please save your image with an RGB colorspace.")
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
