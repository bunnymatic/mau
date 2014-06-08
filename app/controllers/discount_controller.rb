require 'rdiscount'
class DiscountController < ApplicationController
  before_filter :admin_required

  def markup
    html = MarkdownService.markdown(params[:markdown])
    render :text => html
  end
end
