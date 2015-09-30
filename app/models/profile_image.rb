class ProfileImage

  attr_reader :upload, :object

  def initialize(obj)
    @object = obj
  end

  # def datafile
  #   @datafile ||= upload['datafile']
  # end

  # def uploaded_filename
  #   @uploaded_filename ||= datafile.original_filename
  # end

  def dir_prefix
    @dir_prefix ||= ((object.is_a? Studio) ? 'studiodata' : 'artistdata')
  end

  def dir
    @dir ||= (File.join %W|public #{dir_prefix} #{object.id.to_s} profile|)
  end

  # def filename
  #   @filename ||= "profile#{File.extname(uploaded_filename)}"
  # end

  # def save upload
  #   @upload = upload
  #   info = ImageFile.new.save(upload, dir, filename)
  #   object.update_attributes!({:profile_image => info.path,
  #                              :image_height => info.height,
  #                              :image_width => info.width})
  # end
end
