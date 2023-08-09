module Api
  class NotesController < ApiController
    def create
      f = FeedbackMail.new(feedback_mail_params.merge(current_user:))
      unless f.save
        render json: { success: false, error_messages: f.errors.full_messages }, status: :bad_request
        return
      end
      render json: { success: true }, status: :ok
    end

    private

    def feedback_mail_params
      params.require(:feedback_mail).permit(
        :email,
        :email_confirm,
        :question,
        :note_type,
        :os,
        :browser,
        :device,
        :version,
      )
    end
  end
end
