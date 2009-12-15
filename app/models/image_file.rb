require 'mojo_magick'
require 'pathname'

#MojoMagick::set_limits(:area => '128mb', :memory => '128mb', :map => '128mb')

class ImageFile

  @@IMG_SERVERS = ['']
  if Conf.image_servers
    Conf.image_servers.each do |svr|
      @@IMG_SERVERS << svr
    end
  end
  RAILS_DEFAULT_LOGGER.info("IMAGE SERVERS %s" % @@IMG_SERVERS)

  @@ALLOWED_IMAGE_EXTS = ["jpg", "jpeg" ,"gif","png" ]
  @@SIZES = { 
    :thumb => { :w => 100, :h => 100 }, 
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
    when "thumb"
      prefix = "t_"
    when "medium"
      prefix = "m_"
    when "standard"
      prefix = "m_"
#    when "large"
#      prefix = "l_"
    else
      prefix = "m_"
    end
    svr = choice(@@IMG_SERVERS, 1)[0]
    svr + dir + prefix + fname
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
    destfile = destfile.gsub(' ','')
    dir = File.join( destdir)
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
    fmt = MojoMagick::raw_command('identify','-format "%m %h %w" ' + srcpath)
    (type, height, width) = fmt.split
    if @@ALLOWED_IMAGE_EXTS.index(type.downcase) == nil
      raise ArgumentError, "Image type %s is not supported." % type
    end
    height = height.to_i
    width = width.to_i

    # store resized versions:
    file_match = Regexp.new(destfile + "$")
    thumb_path = srcpath.gsub(file_match, "t_"+destfile)
    small_path = srcpath.gsub(file_match, "s_"+destfile)
    med_path = srcpath.gsub(file_match, "m_"+destfile)
#    large_path = srcpath.gsub(file_match, "l_"+destfile)
    begin
      MojoMagick::resize(srcpath, med_path, 
                       { :width => sizes[:std][:w],
                         :height => sizes[:std][:h],
                         :shrink_only => true })
      logger.debug("ImageFile: wrote %s" % med_path)
      MojoMagick::resize(med_path, small_path, 
                       { :width => sizes[:small][:w],
                         :height => sizes[:small][:h],
                         :shrink_only => true })
      logger.debug("ImageFile: wrote %s" % small_path)
      MojoMagick::resize(small_path, thumb_path, 
                       { :width => sizes[:thumb][:w],
                         :height => sizes[:thumb][:h],
                         :shrink_only => true })
      logger.debug("ImageFile: wrote %s" % thumb_path)
#      MojoMagick::resize(srcpath, large_path, 
#                       { :width => sizes[:large][:w],
#                         :height => sizes[:large][:h],
#                         :shrink_only => true })
#      logger.debug("ImageFile: wrote " + large_path)
    rescue
      logger.error("ImageFile: ERROR : %s\n" % $!)
    end
    logger.info("Image conversion took %0.2f sec" % (Time.now.to_f - ts) )
    [ path, height, width ]
  end
end
