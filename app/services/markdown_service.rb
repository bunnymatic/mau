class MarkdownService

  def self.markdown(discount, markdown_opts = :smart)
    RDiscount.new(discount || '', markdown_opts).to_html.html_safe
  end

end
