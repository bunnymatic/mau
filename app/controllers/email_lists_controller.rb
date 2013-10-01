class EmailListsController < ApplicationController
  before_filter :admin_required
  layout 'mau-admin'
  def index
    @all_lists = {
      :feedback => FeedbackMailerList.first.emails,
      :event => EventMailerList.first.emails,
      :admin => AdminMailerList.first.emails
    }
    @purpose = {
      :feedback => 'This list is used to notify MAU staff that someone submitted feedback via the Feedback popup dialog.',
      :event => 'This list is used to notify MAU staff when a new event is added.',
      :admin => 'This list is used to notify MAU Admins - typically for system issues.'
    }
    # :admin => AdminMailerList.first.emails  - not used


    msgs = {}
    if request.post?
      unless ["method", "listtype"].all?{|required| params.has_key? required}
        msgs[:error] = "You did not have all the required parameters"
      end
      email_list_class = {'admin' => AdminMailerList, 'feedback' => FeedbackMailerList, 'event' => EventMailerList}[params['listtype'].to_s]
      if !email_list_class
        msgs[:error] = "We couldn't find that list type to modify"
      else
        email_list = email_list_class.first
      end
      case params['method']
      when 'remove_email'
        if email_list && params["email"] && params["email"]["id"]
          em_id = params["email"]["id"].to_i
          begin
            email = Email.find(em_id)
            member = EmailListMembership.find(:email_list_id => email_list.id, :email_id => email.id)
            member.destroy if member.present?
            msgs[:notice] = "Successfully removed #{email.email} from #{params['listtype'].to_s.capitalize}s"
          rescue Exception => ex
            msgs[:error] = ex.to_s
          end
        else
          msgs[:error] = "Email ID is missing"
        end
      when 'add_email'
        if email_list && params["email"].present?
          new_email = Email.find_or_create(params["email"])
          if new_email.valid?
            unless email_list.emails.include? new_email
              email_list.emails << new_email
              email_list.save
              msgs[:notice] = "Successfully added #{new_email.email} to #{params['listtype'].to_s.capitalize}s"
            end
          else
            msgs[:error] = new_email.errors.full_messages.join('<br/>')
          end
        end
      else
        # didn't match method
      end
      if request.xhr?
        response_data = {}
        status = 200
        msgs.reject{|k,v| v.nil?}.each do |k,v|
          response_data[:messages] = '' if !response_data[:messages]
          response_data[:messages] += v
        end
        status = 400 if msgs[:error].present?
        render :json => response_data, :status => status
      else
        msgs.reject{|k,v| v.nil?}.each do |k,v|
          flash[k] = v
        end
        redirect_to email_lists_path
      end
    end

  end
end
