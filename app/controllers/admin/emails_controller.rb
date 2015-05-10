module Admin
  class EmailsController < BaseAdminController

    def index
      load_email_list
      render json: @email_list.emails
    end
    
    def destroy
      member = EmailListMembership.where(:email_list_id => @email_list.id, :email_id => @email.id).first
      member.destroy if member.present?
      @msgs[:notice] = "Successfully removed #{email.email} from #{@email_list.type}"
      response_data = {}
      response_data[:messages] = @msgs.reject{|k,v| v.nil?}.map{|k,v| v}.join
      status = (@msgs[:error].present? ? 400 : 200)
      render :json => response_data, :status => status
    end

    def create
      load_email_list
      if @email_list
        @email_list.emails.create(email_params)
      end
      render json: {success: true, emails: @email_list.reload.emails}
    end

    private
    def load_email_list
      @email_list = EmailList.find(params[:email_list_id])
    end

    def load_email
      @email = Email.find(params[:id])
    end

    def email_params
      params.require(:email).permit(:name, :email)
    end
  end
end
