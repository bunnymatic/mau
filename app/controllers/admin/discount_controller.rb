# frozen_string_literal: true
require 'rdiscount'
module Admin
  class DiscountController < ::BaseAdminController
    skip_before_action :verify_authenticity_token, only: [:markup]
    def markup
      html = MarkdownService.markdown(markup_params)
      render html: html
    end

    private

    def markup_params
      params.permit(:markdown)[:markdown]
    end
  end
end
