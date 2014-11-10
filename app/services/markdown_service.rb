class MarkdownService
  def self.cleanse(str)
    doc = Nokogiri::HTML::DocumentFragment.parse(str)
    doc.xpath(".//script").remove
    doc.to_s
  end

  def self.markdown(discount, markdown_opts = :smart)
    cleanse(RDiscount.new(discount || '', markdown_opts).to_html).html_safe
  end
end
