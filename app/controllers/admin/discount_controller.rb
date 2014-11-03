require 'rdiscount'
module Admin
  class DiscountController < BaseAdminController
    def markup
      html = MarkdownService.markdown(params[:markdown])
      render :text => html
    end
  end
end
