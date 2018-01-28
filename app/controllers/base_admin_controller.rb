# frozen_string_literal: true

class BaseAdminController < ApplicationController
  layout 'admin'

  before_action :editor_or_manager_required
  before_action :add_admin_body_class

  def add_admin_body_class
    add_body_class 'admin'
  end
end
