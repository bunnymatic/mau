class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :logged_out_required, :only => [:new]
  before_filter :admin_required, :only => [ :unsuspend, :purge, :admin_index, :admin_update, :destroy ]
  before_filter :login_required, :only => [ :edit, :update, :suspend, :delete_art, :destroyart, :upload_profile,
                                            :add_profile, :deactivate, :setarrangement, :arrange_art,
                                            :add_favorite, :remove_favorite, :change_password_update, :notify]

  after_filter :store_location, :only => [ :edit, :show, :add_profile, :favorites ]

  layout 'mau1col'

  DEFAULT_ACCOUNT_TYPE = 'MAUFan'

  def index
    redirect_to artists_path
  end

  def edit
    if current_user.is_artist?
      redirect_to edit_artist_path(current_user)
      return
    end
  end

  def show
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

  # render new.rhtml
  def new
    artist = Artist.new
    fan = MAUFan.new
    @studios = Studio.all
    @type = (['Artist','MAUFan'].include? params[:type]) ? params[:type] : 'Artist'
    @user = (@type == 'MAUFan') ? fan : artist
  end

  def add_profile
  end

  def favorites
    @user = safe_find_user(params[:id])
    if !@user or @user.suspended?
      @user = nil
      flash.now[:error] = "The account you were looking for was not found."
      redirect_back_or_default("/")
      return
    end
    if @user == current_user && current_user.favorites.count <= 0
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
      redirect_to add_profile_users_path
      return
    end

    begin
      post = ArtistProfileImage.new(@user).save upload
      redirect_to user_path(@user), :notice => 'Your profile image has been updated.'
    rescue
      logger.error("Failed to upload %s" % $!)
      flash[:error] = "%s" % $!
      redirect_to add_profile_users_path
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
    @type = params.delete(:type) || DEFAULT_ACCOUNT_TYPE

    # validate email domain
    build_user_from_params
    unless verify_recaptcha
      @user.errors.add(:base, "Failed to prove that you're human."+
                       " Re-type your password and the blurry words at the bottom before re-submitting.")
      render_on_failed_create and return
    end
    if @user.valid? && @user.save
      @user.register!
      redirect_after_create and return
    else
      render_on_failed_create and return
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
          redirect_to request.referer || current_user
        else
          flash[:error] = "Password not changed"
          redirect_to request.referer || current_user
        end

      else
        flash[:error] = "New Password mismatch"
        redirect_to request.referer || current_user
      end
    else
      flash[:error] = "Old password incorrect"
      redirect_to request.referer || root_path
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
    _id = params[:id]
    note_info = build_note_info_from_params
    if note_info.has_key? 'reason'
      AdminMailer.spammer(note_info).deliver!
    elsif note_info['comment'].present?
      ArtistMailer.notify( Artist.find(_id), note_info).deliver!
    end
    render :layout => false
  end

  def reset
    @user = User.find_by_reset_code(params["reset_code"]) unless params["reset_code"].nil?

    if @user.nil?
      flash[:error] = "We were unable to find a user with that activation code"
      render_not_found Exception.new('failed to find user with activation code')
      return
    end
    if request.post? && user_params

      if @user.update_attributes(user_params.slice(:password, :password_confirmation))
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}"
        redirect_back_or_default('/')
        return
      else
        flash[:error] = "Failed to update your password."
        @user.password = '';
        @user.password_confirmation ='';
      end
    end
    respond_to do |fmt|
      fmt.html { render :action => :reset }
      fmt.mobile { render :action => :reset, :layout => 'mobile' }
    end
  end

  def destroy
    id = params[:id]
    u = safe_find_user(id)
    if u
      if u != current_user
        name = u.login
        u.delete!
        flash[:notice] = "The account for login %s has been deactivated." % name
      else
        flash[:error] = "You can't delete yourself."
      end
    else
      flash[:error] = "Couldn't find user #{id}"
    end
    redirect_to users_path and return
  end


  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      user.subscribe_and_welcome
      flash[:notice] = "Signup complete! Please sign in to continue."
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
    else
      flash[:error]  = "We couldn't find an artist with that activation code -- check your email?"+
        " Or maybe you've already activated -- try signing in."
    end
    redirect_to '/login'
  end

  def resend_activation
    if request.post?
      if params[:user]
        user = User.find_by_email(params[:user][:email])
        if user
          if user.class == Artist
            user.resend_activation
            flash[:notice] = "We sent your activation code to #{user.email}. Please check your email for instructions."
          else
            flash[:notice] = "MAU Fan accounts need no activation.  If you've forgotten your password,"+
              " click the 'login' link and follow the 'forgot your password?' link"
          end
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
          flash[:notice] = "We've sent email to #{user.email} with instructions on how to reset your password."+
            "  Please check your email."
        else
          flash[:error] = "That account is not yet active.  Have you responded to the activation email we"+
            " already sent?  Enter your email below if you need us to send you a new activation email."
          redirect_back_or_default('/resend_activation')
          return
        end
      else
        flash[:error] = "No account with email #{params[:user][:email]} exists.  Are you sure you got the"+
          " correct email address?"
      end
      redirect_back_or_default('/login')
    end
  end

  def deactivate
    suspend
    logout_killing_session!
    flash[:notice] = "Your account has been deactivated."
  end

  # def unsuspend
  #   @user.unsuspend!
  #   flash[:notice] = "Your account has been unsuspended"
  #   redirect_to "/"
  # end

  # def suspend
  #   current_user.suspend!
  #   flash[:notice] = "Your account has been suspended"
  #   redirect_to "/"
  # end

  # def purge
  #   @user.destroy!
  #   flash[:notice] = "Your account has been deactivated."
  #   redirect_to "/"
  # end


  # POST
  def add_favorite
    type = params[:fav_type]
    _id = params[:fav_id]
    if Favorite::FAVORITABLE_TYPES.include? type
      obj = type.constantize.find(_id)
      r = current_user.add_favorite(obj) if obj
      if request.xhr?
        render :json => {
          :message => 'Added a favorite',
          :favorite => obj.to_json
        } and return
      else
        objname = obj.get_name(true)
        msg = r ? "#{objname} has been added to your favorites.":
          "You've already added #{objname} to your list of favorites."
        redirect_to obj, :flash => { :notice => msg.html_safe }
      end
    else
      render_not_found({:message => "You can't favorite that type of object" })
    end
  end

  def remove_favorite
    # POST
    type = params[:fav_type]
    _id = params[:fav_id]
    if Favorite::FAVORITABLE_TYPES.include? type
      obj = type.constantize.find(_id)
      if obj
        current_user.remove_favorite(obj)
      end
      if request.xhr?
        render :json => {:message => 'Removed a favorite'}
        return
      else
        flash[:notice] = "#{obj.get_name true} has been removed from your favorites."
        redirect_to(request.referrer || obj)
      end
    else
      render_not_found({:message => "You can't unfavorite that type of object" })
    end
  end

  protected
  def render_on_failed_create
    msg = "There was a problem creating your account."+
          " If you can't solve the issues listed below, please try again later or"+
          " contact the webmaster (link below). if you continue to have problems.<br/>"
    msg += @user.errors.full_messages.join("<br/>") if (@user && @user.errors.present?)
    flash.now[:error] = msg.html_safe
    @studios = Studio.all
    render :action => 'new'
  end

  def redirect_after_create
    if @type == 'Artist'
      @user.reload
      @user.build_artist_info
      @user.artist_info.save!
      @user.save!
      Messager.new.publish "/artists/create", "added a new artist"
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_to root_path
    else
      @user.activate!
      @user.subscribe_and_welcome
      flash[:notice] = "Thanks for signing up!  Login and you're ready to roll!"
      redirect_to login_path
    end
  end

  def safe_find_user(id)
    begin
      User.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The user you were looking for was not found."
      return nil
    end
  end

  def user_params
    @user_params ||= (params[:artist] || params[:mau_fan] || params[:user] || {})
  end

  def build_user_from_params
    return if user_params.empty?
    if @type == 'Artist'
      # studio_id is in artist info
      studio_id = user_params[:studio_id] ? user_params[:studio_id].to_i() : 0
      if studio_id > 0
        studio = Studio.find(studio_id)
        if studio
          @user = studio.artists.build(user_params)
        end
      else
        @user = Artist.new(user_params)
      end
    elsif @type == 'MAUFan' || @type == 'User'
      user_params[:login] = user_params[:login] || user_params[:email]
      @user = MAUFan.new(user_params)
    end
  end

  def basic_note_info_from_params
    {}.tap do |info|
      ['comment','login','email','page','name'].each do |k|
        if params.include? k
          info[k] = params[k]
        end
      end
    end
  end

  def scammer_emails
    @scammer_email ||=
      begin
        fixed_names = ['philipcolee@yahoo.com','evott@rocketmail.com', 'mrsute14@yahoo.com','garymartin@gmail.com]']
        Scammer.all.map(&:email) + fixed_names
      end
  end

  def build_note_info_from_params
    _id = params[:id]
    note_info = basic_note_info_from_params
    if params.include? 'i_love_honey'
      # spammer hit the honey pot.
      note_info['artist_id'] = _id
      note_info['reason'] = 'hit the honey pot'
    elsif scammer_emails.include? note_info['email']
      note_info['artist_id'] = _id
      note_info['reason'] = 'matches suspect scammer email address'
    elsif /Morning,I would love to purchase/i =~ note_info['comment']
      note_info['artist_id'] = _id
      note_info['reason'] = 'matches suspect spam intro'
    elsif /\s+details..i/i =~ note_info['comment']
      note_info['artist_id'] = _id
      note_info['reason'] = 'matches suspect spam intro'
    end
    note_info
  end

end
