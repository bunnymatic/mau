class TestsController < ApplicationController
  # GET /studios
  # GET /studios.xml
  before_filter :admin_required
  layout 'mau1col'

end
