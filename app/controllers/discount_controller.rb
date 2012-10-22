require 'rdiscount'
class DiscountController < ApplicationController
  before_filter :admin_required
  def markup
    begin
      html = RDiscount.new(params[:markdown]).to_html
    rescue Exception => ex
      html = "somethin went wrong<br/> #{ex}"
    end
    render :text => html
  end
end
