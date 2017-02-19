module ImageFileHelpers

  FILENAME_CLEANER = /[\#|\*|\(|\)|\[|\]|\{|\}|\&|\<|\>|\$|\!\?|\;|\']/
  def clean_filename(fname)
    fname.gsub(FILENAME_CLEANER,'').gsub(/\s+/, '')
  end

  # def full_image_path(fname)
  #   return fname if fname.starts_with?("http")
  #   'http://' + Conf.site_url + fname
  # end
end
