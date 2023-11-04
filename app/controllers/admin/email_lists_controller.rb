module Admin
  class EmailListsController < ::BaseAdminController
    def index
      @all_lists = {
        feedback: FeedbackMailerList.instance,
        admin: AdminMailerList.instance,
        watcher: WatcherMailerList.instance,
        sign_up_support: SignUpSupportMailerList.instance,
      }
      @purpose = {
        feedback: 'This list is used to notify MAU staff that someone ' \
                  'submitted feedback via the Feedback popup dialog.',
        admin: 'This list is used to notify MAU Admins - typically for system issues.',
        watcher: 'We notify this list when new art has been created',
        sign_up_support: 'Requests for the secret word and other sign up queries',
      }
    end
  end
end
