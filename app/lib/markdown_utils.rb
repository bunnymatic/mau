module MarkdownUtils
  def markdown(discount, markdown_opts = nil)
    RDiscount.new(discount || '', markdown_opts).to_html.html_safe
  end
  def self.markdown(discount, markdown_opts = nil)
    RDiscount.new(discount || '', markdown_opts).to_html.html_safe
  end
end
