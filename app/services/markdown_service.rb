class MarkdownService

  DEFAULT_MARKDOWN_OPTS = [:smart, :filter_styles, :safelink, :no_pseudo_protocols]

  def self.markdown(discount, markdown_opts = nil)
    markdown_opts ||= DEFAULT_MARKDOWN_OPTS
    cleanse(RDiscount.new((discount || '').lstrip, *markdown_opts).to_html).html_safe
  end

  class << self

    private
    def cleanse(str)
      doc = Nokogiri::HTML::DocumentFragment.parse(str)
      doc.xpath(".//script|pre|code").remove
      doc.to_s
    end

  end

end
