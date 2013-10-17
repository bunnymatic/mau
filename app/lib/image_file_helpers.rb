module ImageFileHelpers

  FILENAME_CLEANER = /[\#|\*|\(|\)|\[|\]|\{|\}|\&|\<|\>|\$|\!\?|\;|\']/
  def clean_filename(fname)
    fname.gsub(FILENAME_CLEANER,'').gsub(/\s+/, '')
  end

  def get_file_extension(fname)
    ext = File::extname(fname).gsub /^\./, ''
    if ext.empty?
      raise(ArgumentError, "Cannot determine file type without an extension.")
    end
    ext
  end

  def create_timestamped_filename(fname)
    ts = Time.zone.now.to_i
    clean_filename("#{ts}#{File::basename(fname)}")
  end
end
