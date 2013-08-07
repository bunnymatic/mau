module TagMediaMixin
  def safe_name
    HTMLHelper.encode(self.name).gsub(' ', '&nbsp;').html_safe
  end
end
