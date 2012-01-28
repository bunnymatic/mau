class EmailListController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'
  def index
    @recipients = EmailList.all
  end
end
