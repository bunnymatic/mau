# frozen_string_literal: true
module Admin
  class EmailListsController < ::BaseAdminController
    def index
      @all_lists = {
        feedback: FeedbackMailerList.first,
        admin: AdminMailerList.first
      }
      @purpose = {
        feedback: 'This list is used to notify MAU staff that someone'\
                     ' submitted feedback via the Feedback popup dialog.',
        admin: 'This list is used to notify MAU Admins - typically for system issues.'
      }
    end
  end
end
