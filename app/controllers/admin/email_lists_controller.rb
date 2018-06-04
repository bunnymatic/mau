# frozen_string_literal: true

module Admin
  class EmailListsController < ::BaseAdminController
    def index
      @all_lists = {
        feedback: FeedbackMailerList.first,
        admin: AdminMailerList.first,
        watcher: WatcherMailerList.first
      }
      @purpose = {
        feedback: 'This list is used to notify MAU staff that someone'\
                     ' submitted feedback via the Feedback popup dialog.',
        admin: 'This list is used to notify MAU Admins - typically for system issues.',
        watcher: 'We notify this list when new art has been created'
      }
    end
  end
end
