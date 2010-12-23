# -*- coding: undecided -*-

class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :admin_required, :only => [ :unsuspend, :purge, :admin_index, :admin_emails, :admin_update, :destroy ]
  before_filter :login_required, :only => [ :edit, :update, :suspend, :deleteart, :destroyart, :upload_profile, 
                                            :addprofile, :deactivate, :setarrangement, :arrangeart, 
                                            :add_favorite, :remove_favorite, :reset, :change_password_update]

  layout 'mau1col'

  @@DEFAULT_ACCOUNT_TYPE = 'MAUFan'
  @@FAVORITABLE_TYPES = ['Artist','ArtPiece']
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

  def favorites
    if !params[:id]
      redirect_back_or_default("/")
      return
    end
    @user = safe_find_user(params[:id])
    if !@user or @user.suspended?
      @user = nil
      flash.now[:error] = "The account you were looking for was not found."
      redirect_back_or_default("/")
      return
    end
    if @user == current_user && current_user.favorites.count <= 0
      tmph = {}
      @random_picks = ArtPiece.find_random(24)
    end
  end

  def upload_profile
    if commit_is_cancel
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
      redirect_to addprofile_users_path
      return
    end
  end

  def update
    if commit_is_cancel
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
    params.delete :type
    user_params = params[:artist] || params[:mau_fan] || params[:user] || {}
    if user_params.empty?
      logger.debug("Failed to create account - bad/empty params")
      render_not_found Exception.new("We can't create a user based on your input parameters.")
      return
    end
    if type == 'Artist'
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
      success = @artist && @artist.valid?
      @artist.register! if success
      errs = @artist.errors
    elsif type == 'MAUFan' || type == 'User'
      user_params[:login] = user_params[:login] || user_params[:email]
      @fan = MAUFan.new(user_params)
      if @fan.url && @fan.url.index('http') != 0
        @fan.url = 'http://' + @fan.url
      end
      success = @fan && @fan.valid?
      @fan.register! if success
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
      if type == 'Artist'
        @artist.reload
        @artist.build_artist_info
        @artist.save!
        flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
        redirect_to "/"
      else
        flash[:notice] = "Thanks for signing up!  Login and you're ready to roll!"
        redirect_to login_path
      end
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
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      self.current_user = @user
      @user.delete_reset_code
      flash[:notice] = "Password reset successfully for #{@user.email}"
      redirect_back_or_default('/')
    else
      render :action => :reset
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
      if params[:user]
        user = User.find_by_email(params[:user][:email])
        if user
          user.resend_activation
          flash[:notice] = "We sent your activation code to #{user.email}.  Please check your email for instructions."
        else
          flash[:error] = "We can't find any users with email #{params[:user][:email]} in our system."
        end
      end
      redirect_back_or_default('/')
    end
  end
    
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
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
        flash[:error] = "No account with email #{params[:user][:email]} exists.  Are you sure you got the correct email address?"
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
  

  def add_favorite
    # POST
    type = params[:fav_type]
    _id = params[:fav_id]
    if @@FAVORITABLE_TYPES.include? type
      obj = type.constantize.find(_id)
      if obj
        r = current_user.add_favorite(obj)
      end
      result = {:message => 'Added a favorite', :favorite => obj.to_json }
      if request.xhr?
        render :json => result
        return
      else
        objname = (obj.class == Artist) ? obj.get_name(true) : obj.safe_title
        path = (obj.class == Artist) ? user_path(obj) : art_piece_path(obj)
        msg = r ? "#{objname} has been added to your favorites.":
          "You've already added #{objname} to your list of favorites."
        flash[:notice] = msg
        redirect_back_or_default(obj)
      end
    else
      render_not_found({:message => "You can't favorite that type of object" })
    end
  end

  def remove_favorite
    # POST
    referrer = request.referer
    type = params[:fav_type]
    _id = params[:fav_id]
    result = {}
    if @@FAVORITABLE_TYPES.include? type
      obj = type.constantize.find(_id)
      if obj
        current_user.remove_favorite(obj)
      end
      if request.xhr?
        render :json => {:message => 'Removed a favorite'}
        return
      else
        flash[:notice] = "#{obj.get_name true} has been removed from your favorites."
        redirect_to referrer || obj
      end
    else
      render_not_found({:message => "You can't unfavorite that type of object" })
    end
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

