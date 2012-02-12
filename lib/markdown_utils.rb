module MarkdownUtils
  def markdown discount
    RDiscount.new(discount || '').to_html
  end

end
