# == Schema Information
#
# Table name: cms_documents
#
#  id         :integer          not null, primary key
#  page       :string(255)
#  section    :string(255)
#  article    :text
#  created_at :datetime
#  updated_at :datetime
#

class CmsDocument < ActiveRecord::Base

  before_save :clean_newlines
  extend MarkdownUtils

  validates :page, :presence => true, :length => {:within => (2..255)}
  validates :article, :presence => true, :length => {:minimum => 2}

  def self.packaged(page, section)
    pkg = {
      :page => page.to_s,
      :section => section.to_s,
    }
    markdown_content = where(:page => page.to_s, :section => section.to_s).first

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
