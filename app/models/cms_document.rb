class CmsDocument < ApplicationRecord

  before_save :clean_newlines

  validates :page, :presence => true, :length => {:within => (2..255)}
  validates :article, :presence => true, :length => {:minimum => 2}

  belongs_to :user

  def self.packaged(page, section)
    pkg = {
      :page => page.to_s,
      :section => section.to_s,
    }
    markdown_content = where(:page => page.to_s, :section => section.to_s).first

    if !markdown_content.nil?
      pkg[:content] = MarkdownService.markdown(markdown_content.article)
      pkg[:cmsid] = markdown_content.id
    end
    pkg
  end

  private
  def clean_newlines
    self.article = self.article.gsub(/\r\n/, "\n");
  end

end
