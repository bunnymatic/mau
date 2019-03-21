# frozen_string_literal: true

module Api
  class NotesController < ApiController
    def create
      f = FeedbackMail.new(feedback_mail_params.merge(current_user: current_user))
      data = {}
      if f.save
        data = { success: true }
        status = 200
      else
        data = {
          success: false,
          error_messages: f.errors.full_messages,
        }
        status = 400
      end
      render json: data, status: status
    end

    private

    def feedback_mail_params
      params.require(:feedback_mail).permit(
        :email,
        :email_confirm,
        :inquiry,
        :note_type,
        :os,
        :browser,
        :device,
        :version,
      )
    end
  end
end
