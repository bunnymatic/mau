class ProfileImage

  attr_reader :upload, :object

  def initialize(upload, obj)
    @upload = upload
    @object = obj
  end

  def datafile
    @datafile ||= upload['datafile']
  end

  def uploaded_filename
    @uploaded_filename ||= datafile.original_filename
  end

  def dir_prefix
    @dir_prefix ||= object.class.name.downcase + 'data'
  end

  def dir
    @dir ||= (File.join %W|public #{dir_prefix} #{object.id.to_s} profile|)
  end

  def filename
    @filename ||= "profile#{File.extname(uploaded_filename)}"
  end

  def save
    image = ImageFile.new(upload, dir, filename)
    info = image.save
    object.update_attributes!({:profile_image => info.path,
                               :image_height => info.height,
                               :image_width => info.width})
  end
end
