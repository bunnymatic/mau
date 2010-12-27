require 'rand_helpers'
require 'open-uri'
require 'rss/1.0'
require 'rss/2.0'
require 'ftools'
FEEDS_KEY = 'news-feeds'

class MainController < ApplicationController
  layout 'mau2col'
  before_filter :no_cache, :only => :index
  @@CACHE_EXPIRY = (Conf.cache_expiry['feed'] or 20)
  def index
    @rand_pieces = MainHelper.get_random_pieces
    respond_to do |format| 
      format.html { render }
      format.json { render :json => @rand_pieces.to_json(:include => [:artist]) }
    end
  end

  def faq
  end

  def sampler
    @rand_pieces = MainHelper.get_random_pieces
    render :partial => '/art_pieces/thumbs', :locals => { :pieces => @rand_pieces, :params => { :cols => 5 }}
  end

  def version
    render :text => self.revision
  end

  def getinvolved
    @page_title = "Mission Artists United - Get Invovled!"
    @page = params[:p]

    if @page == 'paypal_success'
      flash.now[:notice] = "Thanks for your donation!  We'll spend it wisely."
    end
    if @page == 'paypal_cancel'
      flash.now[:error] = "Did you have problems submitting your donation?  If so, please tell us with the feedback link at the bottom of the page.  We'd love to know if the website or the PayPal connection is not working."
    end

    if params[:commit]
      if params[:feedback][:email].empty?
        flash.now[:error] = "There was a problem submitting your feedback.  Your email was blank."
        return
      end
      if params[:feedback][:comment].empty?
        flash.now[:error] = "There was a problem submitting your feedback.  Please fill something in for the comment."
        return
      end
      
      feedback = Feedback.new(params[:feedback])
      saved = feedback.save
      if saved
        FeedbackMailer.deliver_feedback(feedback)
        flash.now[:notice] = "Thank you for your submission!  We'll get on it as soon as we can."
      else
        flash.now[:error] = "There was a problem submitting your feedback.  Was your comment empty?"
      end
    end
  end

  def openstudios
    @page_title = "Mission Artists United - Open Studios"
  end

  def about
    @show_history = false
    if params[:id] == 'h'
      @show_history = true
    end
    @page_title = "Mission Artists United - About Us"
  end

  def notes_mailer
    if !request.xhr?
      render_not_found("Method Unavaliable")
      return 
    end
    resp_hash = MainController::validate_params(params) 
    if resp_hash[:messages].size < 1
      # process
      email = params["email"]
      subject = params["note_type"]
      login = current_user ? current_user.login : 'anon'
      case params["note_type"]
      when 'inquiry'
        comment = "From: #{email}\nQuestion: #{params['inquiry']}"
      when 'email_list'
        comment = "From: #{email}\n Add me to your email list"
      end
      f = Feedback.new( { :email => email,
                          :subject => subject, 
                          :login => login,
                          :comment => comment })
      if f.save
        FeedbackMailer.deliver_feedback(f)
      end
    end

    render :json => resp_hash
  end

  def news
    @feedhtml = ''
    numentries = 5
    url, link = 'http://missionartistsunited.wordpress.com/feed/',
    'http://missionartistsunited.wordpress.com'
    begin
      cached_html = Rails.cache.read(FEEDS_KEY)
    rescue
      cached_html = nil
    end
    if !cached_html or cached_html.empty?
      cached_html = FeedsHelper.fetch_and_format_feed(url, link, 5, true, true, true)
      begin
        Rails.cache.write(FEEDS_KEY, cached_html, :expires_in => @@CACHE_EXPIRY)
      rescue
        nil
      end
    end
    @page_title = "Mission Artists United - Open Studios"
    @feedhtml = cached_html
  end

  def venues
    # temporary venues endpoint until we actually add a real
    # controller/model behind it
  end
  
  private
  def self.validate_params(params)
    results = { :status => 'success', :messages => [] }

    # common validation
    unless ["inquiry", "email_list"].include? params[:note_type] 
      results[:messages] << "invalid note type"
    else
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
      # specific
      case params[:note_type]
      when 'inquiry' 
        if params['inquiry'].blank?
          results[:messages] << 'note cannot be empty'
          results[:messages] << 'not enough parameters'
        end
      when 'email_list'
      else
      end
    end
    if results[:messages].size > 0
      results[:status] = 'error'
    end
    results
  end
end
