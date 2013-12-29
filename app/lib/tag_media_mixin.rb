module TagMediaMixin
  include HtmlHelper

  def safe_name
    html_encode(self.name).gsub(' ', '&nbsp;').html_safe
  end
end
