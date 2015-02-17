class ViewPresenter

  include HtmlHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  # content_tag with a block
  attr_accessor :output_buffer


end
