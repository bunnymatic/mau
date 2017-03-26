# frozen_string_literal: true
class FeedbacksController < ApplicationController
  layout false

  def _get_title
    'Feedback'
  end

  def new
    @section = 'general'
    @title = _get_title
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)

    if @feedback.save
      FeedbackMailer.feedback(@feedback).deliver_later
      render 'thankyou', status: :created
    else
      @error_message = 'Please enter a comment or hit cancel.'

      # Returns the whole form back. This is not the most effective
      # use of AJAX as we could return the error message in JSON, but
      # it makes easier the customization of the form with error messages
      # without worrying about the javascript.
      @title = _get_title
      @section = @feedback.subject.to_s
      render action: 'new', status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit :subject, :email, :login, :page, :comment, :url, :skillsets, :bugtype
  end
end
