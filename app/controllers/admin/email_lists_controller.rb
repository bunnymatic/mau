module Admin
  class EmailListsController < BaseAdminController

    def destroy
      @msgs = {}
      remove_email(email_list)
      response_data = {}
      response_data[:messages] = @msgs.reject{|k,v| v.nil?}.map{|k,v| v}.join
      status = (@msgs[:error].present? ? 400 : 200)
      render :json => response_data, :status => status
    end

    def add
      @msgs = {}
      add_email(email_list)
      @msgs.reject{|k,v| v.nil?}.each do |k,v|
        flash[k] = v
      end
      redirect_to admin_email_lists_path
    end

    def index
      @all_lists = {
        :feedback => FeedbackMailerList.first.emails,
        :event => EventMailerList.first.emails,
        :admin => AdminMailerList.first.emails
      }
      @purpose = {
        :feedback => 'This list is used to notify MAU staff that someone'+
        ' submitted feedback via the Feedback popup dialog.',
        :event => 'This list is used to notify MAU staff when a new event is added.',
        :admin => 'This list is used to notify MAU Admins - typically for system issues.'
      }

    end


    private
    def insufficient_params?
      !["listtype"].all?{|required| params.has_key? required}
    end

    def email_list
      @email_list ||=
        begin
          clz = {
          'admin' => AdminMailerList,
          'feedback' => FeedbackMailerList,
          'event' => EventMailerList
        }[params['listtype'].to_s]
          if !clz
            @msgs[:error] = "We couldn't find that list type to modify"
            nil
          else
            clz.first
          end
        end
    end

    def handle_email_list_update
      if insufficient_params?
        @msgs[:error] = "You did not have all the required parameters"
      end

      case params['method']
      when 'remove_email'
        remove_email(email_list)
      when 'add_email'
        add_email(email_list)
      else
        # didn't match method
      end
    end

    def remove_email(list)
      email = Email.where(:id => params[:id]).first
      if list && email
        member = EmailListMembership.where(:email_list_id => list.id, :email_id => email.id).first
        member.destroy if member.present?

        @msgs[:notice] = "Successfully removed #{email.email} from #{params['listtype'].to_s.capitalize}s"

      else
        @msgs[:error] = "Email ID is missing"
      end
    end

    def add_email(list)
      if list && params["email"].present?
        new_email = Email.find_or_create(params["email"])
        if new_email.valid?
          unless list.emails.include? new_email
            list.emails << new_email
            list.save
            @msgs[:notice] = "Successfully added #{new_email.email} to #{params['listtype'].to_s.capitalize}s"
          end
        else
          @msgs[:error] = new_email.errors.full_messages.join('<br/>')
        end
      end
    end
  end
end
