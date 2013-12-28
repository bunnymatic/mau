require 'rdiscount'
class DiscountController < ApplicationController
  before_filter :admin_required
  include MarkdownUtils
  def markup
    html = markdown(params[:markdown])
    render :text => html
  end
end
