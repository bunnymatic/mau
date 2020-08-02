# frozen_string_literal: true

class ViewPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  # content_tag with a block
  attr_accessor :output_buffer

  DEFAULT_CSV_OPTS = { row_sep: "\n", force_quotes: true }.freeze

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def csv_safe(val)
    (val || '').gsub(/"',/, '')
  end
end
