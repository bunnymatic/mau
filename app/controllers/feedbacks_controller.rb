class FeedbacksController < ApplicationController
  layout false

  def _get_title
    if logged_in?
      "Get Involved"
    else
      "Feedback"
    end
  end

  def new
    @title = _get_title
    @feedback = Feedback.new    
  end
  
  def create
    
    @feedback = Feedback.new(params[:feedback])
    if @feedback.valid?
      @feedback.save
      #FeedbackMailer.deliver_feedback(@feedback)
      render :status => :created, :text => '<h3>Thank you for your feedback!</h3>'
    else
      @error_message = "Please enter your #{@feedback.subject.to_s.downcase}"
	  
	  # Returns the whole form back. This is not the most effective
      # use of AJAX as we could return the error message in JSON, but
      # it makes easier the customization of the form with error messages
      # without worrying about the javascript.
      @title = _get_title
      render :action => 'new', :status => :unprocessable_entity
    end
    
    
  end
  
end
