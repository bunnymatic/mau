class ViewPresenter

  include HtmlHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  # content_tag with a block
  attr_accessor :output_buffer

  def url_helpers
    Rails.application.routes.url_helpers
  end

end
