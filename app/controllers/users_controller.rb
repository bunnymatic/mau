# -*- coding: undecided -*-
require 'pp'

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :admin_required, :only => [ :unsuspend, :purge, :admin_index, :admin_emails, :admin_update, :destroy ]
  before_filter :login_required, :only => [ :edit, :update, :suspend, :deleteart, :destroyart, :addprofile, :deactivate, :setarrangement, :arrangeart ]

  layout 'mau1col'

  @@DEFAULT_ACCOUNT_TYPE = 'MAUFan'

  def index
    redirect_to('/artists')
  end

  def edit
    if current_user.is_artist?
      redirect_to edit_artist_path(current_user)
      return
    end
  end

  def show
    if params[:id]
      @fan = safe_find_user(params[:id])
      if !@fan or @fan.suspended?
        @fan = nil
        flash.now[:error] = "The account you were looking for was not found."
      end

      if @fan
        if @fan.is_artist?
          redirect_to artist_path(@fan)
          return
        end
        @page_title = "Mission Artists United - Fan: %s" % @fan.get_name(true)
      else
        @page_title = "Mission Artists United"
      end
      render :action => 'show', :layout => 'mau'
    end
  end

  # render new.rhtml
  def new
    if logged_in?
      flash[:notice] = "You're already logged in"
      redirect_to current_artist || user_path(current_user)
    end
    @artist = Artist.new
    @fan = MAUFan.new
    @studios = Studio.all
    #default type
  end

  def addprofile
    @errors = []
    if !current_user
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( user_path(current_user) || "/")
    end
  end

  def upload_profile
    if params[:commit].downcase == 'cancel'
      
      redirect_to user_path(current_user)
      return
    end

    @user = self.current_user
    upload = params[:upload]

    if not upload
      flash[:error] = "You must provide a file."
      redirect_to addprofile_users_path
      return
    end

    begin
      post = ArtistProfileImage.save(upload, @user)
      redirect_to user_path(@user)
      return
    rescue
      logger.error("Failed to upload %s" % $!)
      flash[:error] = "%s" % $!
      redirect_to addprofile_users_path(@user)
      return
    end
  end

  def update
    if params[:commit] && params[:commit].downcase == 'cancel'
      redirect_to user_path(current_user)
      return
    end
    begin
      if params[:emailsettings]
        em = params[:emailsettings]
        em2 = {}
        em.each_pair do |k,v| 
          em2[k] = ( v.to_i != 0 ? true : false)
        end
        params[:user][:email_attrs] = em2.to_json
      end
      # clean os from radio buttons
      self.current_user.update_attributes!(params[:user])
      flash[:notice] = "Update successful"
      redirect_to(edit_user_url(current_user))
    rescue 
      flash[:error] = "%s" % $!
      redirect_to(edit_user_url(current_user))
    end
  end

  def create
    logout_keeping_session!
    user_params = {}
    type = params[:type] || @@DEFAULT_ACCOUNT_TYPE
    user_params = params[:artist] || params[:mau_fan] || params[:user] || {}
    if user_params.empty?
      logger.debug("Failed to create account - bad/empty params")
      render_not_found Exception.new("We can't create a user based on your input parameters.")
      return
    end
    if type == 'Artist'
      user_params[:type] = "Artist"
      # studio_id is in artist info
      studio_id = user_params[:studio_id] ? user_params[:studio_id].to_i() : 0
      @artist = nil
      if studio_id > 0
        studio = Studio.find(studio_id)
        if studio
          @artist = studio.artists.build(user_params)
        end
      else
        @artist = Artist.create(user_params)
      end
      if @artist.url && @artist.url.index('http') != 0
        @artist.url = 'http://' + @artist.url
      end
      @artist.artist_info = ArtistInfo.new
      @artist.register! if @artist && @artist.valid?
      success = @artist && @artist.valid?
      errs = @artist.errors
    elsif type == 'MAUFan' || type == 'User'
      user_params[:type] = "MAUFan"
      user_params[:login] = user_params[:login] || user_params[:email]
      @fan = MAUFan.new(user_params)
      if @fan.url && @fan.url.index('http') != 0
        @fan.url = 'http://' + @fan.url
      end
      @fan.register! if @fan && @fan.valid?
      success = @fan && @fan.valid?
      errs = @fan.errors
    else
      logger.debug("Failed to create account - bad/empty params")
      render_not_found Exception.new("We can't create a user based on your input parameters.")
      return
    end
    if success && errs.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_to "/"
    else
      msg = "There was a problem creating your account.  If you can't solve the issues listed below, please try again later or contact the webmaster (link below). if you continue to have problems."
      flash.now[:error] = msg
      if !@artist
        # make empty artist for the hidden artist form
        @artist = Artist.new
        @type = 'MAUFan'
      end
      if !@fan
        # make empty fan for the hidden fan form
        @fan = MAUFan.new
        @type = 'Artist'
      end
      @studios = Studio.all
      render :action => 'new'
    end
  end
  

  # Change user passowrd
  def change_password_update
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        
        if current_user.save!
          flash[:notice] = "Password successfully updated"
          redirect_to request.env["HTTP_REFERER"] or current_user
        else
          flash[:error] = "Password not changed"
          redirect_to request.env["HTTP_REFERER"] or current_user
        end
        
      else
        flash[:error] = "New Password mismatch" 
        redirect_to request.env["HTTP_REFERER"] or current_user
      end
    else
      flash[:error] = "Old password incorrect" 
      redirect_to request.env["HTTP_REFERER"] or "/"
    end
  end

  def noteform
    # get new note form
    @artist = safe_find_user(params[:id])
    if !@artist
      @errmsg = "We were unable to find the artist in question."
    end
    render :layout => false
  end

  def notify
    id = Integer(params[:id])
    noteinfo = {}
    ['comment','login','email','page','name'].each do |k|
      if params.include? k
        noteinfo[k] = params[k]
      end
    end
    ArtistMailer.deliver_notify( Artist.find(id), noteinfo)
    render :layout => false
  end

  def reset
    @artist = Artist.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @artist.update_attributes(:password => params[:artist][:password], :password_confirmation => params[:artist][:password_confirmation])
        self.current_artist = @artist
        @artist.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@artist.email}"
        redirect_back_or_default('/')
      else
        render :action => :reset
      end
    end
  end

  def destroy
    id = params[:id]
    a = safe_find_user(id)
    if a
      name = a.login
      a.delete!
      flash[:notice] = "The account for login %s has been deactivated." % name
      redirect_to artists_path
    end
  end


  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a artist with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def resend_activation
    if request.post?
      user = User.find_by_email(params[:artist][:email])
      if user
        user.resend_activation
        flash[:notice] = "We sent your activation code to #{user.email}.  Please check your email for instructions."
      else
        flash[:error] = "We can't find any users with email #{params[:artist][:email]} in our system."
      end
      redirect_back_or_default('/')
    end
  end
    
  def forgot
    if request.post?
      user = User.find_by_email(params[:artist][:email])
      if user
        if user.state == 'active'
          user.create_reset_code
          flash[:notice] = "We've sent email to #{user.email} with instructions on how to reset your password.  Please check your email."
        else
          flash[:error] = "That account is not yet active.  Have you responded to the activation email we already sent?  Enter your email below if you need us to send you a new activation email."
          redirect_back_or_default('/resend_activation')
          return
        end
      else
        flash[:error] = "No account with email #{params[:artist][:email]} exists.  Are you sure you got the correct email address?"
      end
      redirect_back_or_default('/login')
    end
  end

  def deactivate
    suspend
    logout_killing_session!
    flash[:notice] = "Your account has been deactivated."
  end

  def unsuspend
    @user.unsuspend!
    flash[:notice] = "Your account has been unsuspended"
    redirect_to "/"
  end
  def suspend
    current_user.suspend!
    flash[:notice] = "Your account has been suspended"
    redirect_to "/"
  end

  def purge
    @user.destroy!
    flash[:notice] = "Your account has been deactivated."
    redirect_to "/"
  end

  protected
  def safe_find_user(id)
    begin
      User.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The user you were looking for was not found."
      return nil
    end
  end

end

