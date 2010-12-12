module TagMediaMixin  
  def safe_name
    HTMLHelper.encode(self.name).gsub(' ', '&nbsp;')
  end
end
