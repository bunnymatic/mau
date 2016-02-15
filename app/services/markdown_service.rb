class MarkdownService

  DEFAULT_MARKDOWN_OPTS = [:smart, :filter_html, :safelink]

  def self.markdown(discount, markdown_opts = nil)
    markdown_opts ||= DEFAULT_MARKDOWN_OPTS
    RDiscount.new((discount || '').lstrip, *markdown_opts).to_html.html_safe
  end
end
