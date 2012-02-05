class CmsDocument < ActiveRecord::Base
  before_save :clean_newlines
  
  private
  def clean_newlines
    self.article = self.article.gsub(/\r\n/, "\n");
  end
end
