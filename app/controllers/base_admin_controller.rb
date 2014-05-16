class BaseAdminController < ApplicationController

  layout 'mau-admin'
  include OsHelper

  before_filter :editor_or_manager_required
  before_filter :add_admin_body_class
  
  def add_admin_body_class
    add_body_class 'admin'
  end
end
