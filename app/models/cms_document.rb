# frozen_string_literal: true

class CmsDocument < ApplicationRecord
  before_save :clean_newlines

  validates :page, presence: true, length: { within: (2..255) }
  validates :article, presence: true, length: { minimum: 2 }

  belongs_to :user

  def self.packaged(page, section)
    pkg = {
      page: page.to_s,
      section: section.to_s
    }
    markdown_content = find_by(page: page.to_s, section: section.to_s)

    unless markdown_content.nil?
      pkg[:content] = MarkdownService.markdown(markdown_content.article)
      pkg[:cmsid] = markdown_content.id
    end
    pkg
  end

  private

  def clean_newlines
    self.article = article.gsub(/\r\n/, "\n")
  end
end
