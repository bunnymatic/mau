require 'rdiscount'
class DiscountController < ApplicationController
  def markup
    html = 'shit'
    begin
      html = RDiscount.new(params[:markdown]).to_html
    rescue Exception => ex
      logger.debug("Failed to markdown text")
      logger.debug(ex)
      html = "shit.<br/> somethin went wrong<br/> #{ex}"
    end
    render :text => html
  end
end
