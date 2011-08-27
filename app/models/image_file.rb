require 'pathname'
require 'RMagick'

class ImageFile

  @@IMG_SERVERS = ['']
  @@FILENAME_CLEANER = '/[\#|\*|\(|\)|\[|\]|\{|\}|\&|\<|\>|\$|\!\?|\;|\'/'
  if Conf.image_servers
    Conf.image_servers.each do |svr|
      @@IMG_SERVERS << svr
    end
    RAILS_DEFAULT_LOGGER.info("IMAGE SERVERS [%s]" % @@IMG_SERVERS)
  end

  @@ALLOWED_IMAGE_EXTS = ["jpg", "jpeg" ,"gif","png" ]
  @@SIZES = { 
    :thumb => { :w => 100, :h => 100 }, 
    :cropped_thumb => { :w => 127, :h => 127 }, 
    :small => { :w => 200, :h => 200 },
    :std => { :w => 400, :h => 400 }}

# leave out large
#    :large => { :w => 1000, :h => 1000 }} 
  
  def self.sizes
    @@SIZES
  end

  def self.get_path(dir, size, fname)
    if not fname or fname.length < 1
      return ''
    end
    prefix = "m_"
    case size
    when "original"
      prefix = ""
    when "small"
      prefix = "s_"
    when "thumb", 'thumbnail'
      prefix = "t_"
    when "medium",'standard'
      prefix = "m_"
    when "cropped_thumb"
      prefix = 'ct_'
#    when "large"
#      prefix = "l_"
    else
      prefix = "m_"
    end
    idx = fname.hash % @@IMG_SERVERS.length
    svr = @@IMG_SERVERS[idx]
    svr + File.join(dir, prefix+fname)
  end

  def self.save(upload, destdir, destfile=nil, sizes=@@SIZES)
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
    image = Magick::Image.read(srcpath).first
    height = image.rows
    width = image.columns
    colorspace = image.colorspace
    type = image.format

    #fmt = MojoMagick::raw_command('identify','-format "%m %h %w %r" ' + srcpath)
    #(type, height, width, colorspace) = fmt.split
    if @@ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise ArgumentError, "Image type %s is not supported." % type
    end
#    if colorspace.downcase.match /cmyk/
    if colorspace == Magick::CMYKColorspace
      raise ArgumentError, "[%s] is not a supported color space.  Please save your image with an RGB colorspace." % colorspace.to_s
    end

    # store resized versions:
    file_match = Regexp.new(destfile + "$")
    paths = [[:std , srcpath.gsub(file_match, "m_"+destfile)],
             [:small , srcpath.gsub(file_match, "s_"+destfile)],
             [:cropped_thumb , srcpath.gsub(file_match, "ct_"+destfile)],
             [:thumb , srcpath.gsub(file_match, "t_"+destfile)]]
    paths.each do |pthinfo|
      begin
        ky = pthinfo[0]
        dest_path = pthinfo[1]
        method = (ky == :cropped_thumb) ? 'resize_to_fill' : 'resize_to_fit'
        img = image.send(method,sizes[ky][:w], sizes[ky][:h])
        img.write(dest_path)
        logger.debug("ImageFile: wrote %s" % dest_path)
      rescue Exception => ex
        logger.error("ImageFile: ERROR : %s\n" % $!)
        puts ex.backtrace unless RAILS_ENV == 'production'
      end
    end
    logger.info("Image conversion took %0.2f sec" % (Time.now.to_f - ts) )
    [ path, height, width ]
  end
end
