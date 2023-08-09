module ImageFileHelpers
  FILENAME_CLEANER = /[\#|*()\[\]{}&<>$!?;']/
  def clean_filename(fname)
    fname.gsub(FILENAME_CLEANER, '').gsub(/\s+/, '')
  end
end
