module MarkdownUtils
  def markdown discount
    RDiscount.new(discount || '').to_html.html_safe
  end

end
