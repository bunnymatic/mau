module Admin
  class EmailsController < ::BaseAdminController
    def index
      load_email_list
      render json: { emails: @email_list.emails }
    end

    def create
      load_email_list
      errors = {}
      if @email_list
        begin
          email = Email.where(email: email_params[:email]).first
          if email
            @email_list.emails << email
            @email_list.save
          else
            new_email = @email_list.emails.create(email_params)
            errors = new_email.errors unless new_email.valid?
          end
        rescue ActiveRecord::RecordInvalid => e
          errors[:email] = e.to_s
        end
      end
      if errors.present?
        render json: { errors: }, status: :bad_request
      else
        render json: { emails: @email_list.reload.emails }
      end
    end

    def destroy
      load_email_list
      load_email
      member = EmailListMembership.where(email_list_id: @email_list.id, email_id: @email.id).first
      member.destroy if member.present?
      render json: { success: true }
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
