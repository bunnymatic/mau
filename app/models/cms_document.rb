class CmsDocument < ActiveRecord::Base

  before_save :clean_newlines
  extend MarkdownUtils

  def self.packaged(page, section)
    pkg = {
      :page => page.to_s,
      :section => section.to_s,
    }
    markdown_content = find(:page => page.to_s, :section => section.to_s)

    if !markdown_content.nil?
      pkg[:content] = markdown(markdown_content.article)
      pkg[:cmsid] = markdown_content.id
    end
    pkg
  end

  private
  def clean_newlines
    self.article = self.article.gsub(/\r\n/, "\n");
  end
end
