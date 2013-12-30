class FeedbackMail

  def initialize(opts)
    @params = opts
  end

  def construct_and_mail_feedback
    resp_hash = MainController::validate_params(params)
    if resp_hash[:messages].size < 1
      # process
      email = params["email"] || ""
      subject = "MAU Submit Form : #{params["note_type"]}"
      login = "anon"
      if current_user
        login = current_user.login
        email += " (account email : #{current_user.email})"
      end
      comment = ''
      comment += "OS: #{params["operating_system"]}\n"
      comment += "Browser: #{params["browser"]}\n"
      case params["note_type"]
      when 'inquiry', 'help'
        comment += "From: #{email}\nQuestion: #{params['inquiry']}\n"
      when 'email_list'
        comment += "From: #{email}\n Add me to your email list\n"
      when 'feed_submission'
        comment += "Feed Link: #{params['feedlink']}\n"
      end

      f = Feedback.new( { :email => email,
                          :subject => subject,
                          :login => login,
                          :comment => comment })
      if f.save
        FeedbackMailer.feedback(f).deliver!
      end
    end
  end

  def validate_params(params)
    results = { :status => 'success', :messages => [] }

    # common validation
    unless ["feed_submission", "help", "inquiry", "email_list"].include? params[:note_type]
      results[:messages] << "invalid note type"
    else
      if !(['feed_submission'].include? params[:note_type])
        ['email','email_confirm'].each do |k|
          if params[k].blank?
            humanized = ActiveSupport::Inflector.humanize(k)
            results[:messages] << "#{humanized} can't be blank"
          end
        end

        if (params.keys.select { |k| ['email', 'email_confirm' ].include? k }).size < 2
          results[:messages] << 'not enough parameters'
        end
        if params['email'] != params['email_confirm']
          results[:messages] << 'emails do not match'
        end
      elsif 'feed_submission' == params[:note_type]
        if (params.keys.select { |k| ['feedlink' ].include? k }).size < 1
          results[:messages] << 'not enough parameters'
        end
      end
      # specific
      case params[:note_type]
      when 'inquiry'
        if params['inquiry'].blank?
          results[:messages] << 'note cannot be empty'
          results[:messages] << 'not enough parameters'
        end
      when 'email_list'
      when 'feed_submission'
        if params["feedlink"].blank?
          results[:messages] << 'feed url can\'t be empty'
        end
      else
      end
    end
    if results[:messages].size > 0
      results[:status] = 'error'
    end
    results
  end

end
