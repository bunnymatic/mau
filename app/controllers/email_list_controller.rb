class EmailListController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'
  def index
    @all_lists = { 
      :feedback => FeedbackMailerList.first.emails,
      :admin => AdminMailerList.first.emails,
      :event => EventMailerList.first.emails 
    }
    
    if request.post?
      unless ["method", "listtype"].all?{|required| params.has_key? required}
        flash.now[:error] = "You did not have all the required parameters"
      end
      email_list_class = {'admin' => AdminMailerList, 'feedback' => FeedbackMailerList, 'event' => EventMailerList}[params['listtype'].to_s]
      if !email_list_class
        flash.now[:error] = "We couldn't find that list type to modify"
      else
        email_list = email_list_class.first
      end
      if email_list && params["method"] == 'add_email' && params["email"].present?
        new_email = Email.find_or_create(params["email"])
        if new_email.valid?
          unless email_list.emails.include? new_email
            email_list.emails << new_email
            email_list.save
          end
        else
          flash.now[:error] = new_email.errors.full_messages.join('<br/>')
        end
      end
    end
      
  end
end
