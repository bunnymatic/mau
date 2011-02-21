class CatalogController < ApplicationController
  layout 'catalog'
  def index
    @map_size = [ 596, 591 ]

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => 'this' }
      #format.pdf { render :pdf => 'this' }
    end
  end
end
