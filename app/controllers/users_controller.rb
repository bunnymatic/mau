class UsersController < ApplicationController

  before_filter :logged_out_required, :only => [:new]
  before_filter :admin_required, :only => [ :admin_index, :admin_update, :destroy ]
  before_filter :user_required, :only => [ :edit, :update, :suspend, :deactivate,
                                           :add_favorite, :remove_favorite, :change_password_update]


  DEFAULT_ACCOUNT_TYPE = 'MAUFan'

  def index
    redirect_to artists_path
  end

  def edit
    if current_user.is_artist?
      redirect_to edit_artist_path(current_user), flash: flash
      return
    end
    @user = UserPresenter.new(current_user.becomes(User))
  end

  def show
    @fan = safe_find_user(params[:id])
    unless @fan && @fan.active?
      flash.now[:error] = "The account you were looking for was not found."
      redirect_to artists_path and return
    end
    if @fan.is_artist?
      redirect_to artist_path(@fan) and return
    else
      @page_title = "Mission Artists United - Fan: %s" % @fan.get_name(true)
    end
    @fan = UserPresenter.new(@fan.becomes(User))
  end

  def new
    artist = Artist.new
    fan = MAUFan.new
    @studios = Studio.all
    type = params[:type] || user_attrs[:type]
    @type = ['Artist','MAUFan'].include?(type) ? type : 'Artist'
    @user = (@type == 'MAUFan') ? fan : artist
  end


  def update
    if commit_is_cancel
      redirect_to user_path(current_user)
      return
    end
    # clean os from radio buttons
    begin
      if params.has_key? 'upload'
        begin
          # update the picture only
          ArtistProfileImage.new(current_user).save params[:upload]
        end
      else
        current_user.update_attributes!(user_params)
        Messager.new.publish "/artists/#{current_user.id}/update", "updated artist info"
      end
      flash[:notice] = "Your profile has been updated"
    rescue Exception => ex
      flash[:error] = ex.to_s
    end
    redirect_to edit_user_url(current_user), flash: flash
  end

  def create
    logout
    @type = params.delete(:type)
    @type ||= user_attrs[:type]

    # validate email domain
    @user = build_user_from_params
    unless verify_recaptcha
      @user.valid?
      @user.errors.add(:base, "Failed to prove that you're human."+
                       " Re-type your password and the blurry words at the bottom before re-submitting.")
      render_on_failed_create and return
    end
    if @user.valid? && @user.save
      new_state = (@user.is_a? Artist) ? 'pending' : 'active'
      @user.update_attribute(:state, new_state)
      redirect_after_create and return
    else
      render_on_failed_create and return
    end
  end

  # Change user passowrd
  def change_password_update
    msg = {}
    if current_user.valid_password? user_attrs["old_password"]
      if current_user.update_attributes(password_params)
        msg[:notice] = "Your password has been updated"
      else
        msg[:error] = current_user.errors.full_messages.join
      end
    else
      msg[:error] = "Your old password was incorrect"
    end
    redirect_to edit_user_path(current_user, anchor: 'password'), flash: msg
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
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}.  Please log in."
        logout
        redirect_to login_path
        return
      else
        flash[:error] = "Failed to update your password."
        @user.password = '';
        @user.password_confirmation ='';
      end
    end
  end

  def destroy
    id = params[:id]
    u = safe_find_user(id)
    if u
      if u.id != current_user.id
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
    logout
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

    redirect_to login_path
  end

  def resend_activation
    if request.post?
      if params[:user] && params[:user][:email].present?
        email = params[:user][:email]
        flash[:notice] = "We sent your activation code to #{email}. Please check your email for instructions."
        user = User.find_by_email email
        if user
          user.resend_activation
        end
        redirect_back_or_default('/')
      else
        flash[:error] = "You need to enter an email"
      end
    end
  end

  def forgot
    if request.post?
      if params[:user] && params[:user][:email].present?
        email = params[:user][:email]
        user = User.find_by_email(params[:user][:email])
        if user
          if !user.active?
            flash[:error] = "That account is not yet active.  Have you responded to the activation email we"+
              " already sent?  Enter your email below if you need us to send you a new activation email."
          else
            flash[:notice] = "We've sent email with instructions on how to reset your password."+
              "  Please check your email."
            user.create_reset_code
            redirect_to login_path and return
          end
        else
          flash[:notice] = "We've sent email with instructions on how to reset your password."+
            "  Please check your email."
        end
      end
      redirect_to login_path
    end
  end

  def deactivate
    logout
    current_user.suspend!
    flash[:notice] = "Your account has been deactivated."
    redirect_to root_path
  end

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
        if obj.is_a? ArtPiece
          redirect_to art_piece_path(obj), :flash => { :notice => msg }
        else
          redirect_to obj, :flash => { :notice => msg }
        end

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
          " contact the webmaster (link below). if you continue to have problems."
    msg += @user.errors[:base].join(". ")
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

  private

  def build_user_from_params
    return if user_params.empty?
    if @type == 'Artist'
      Artist.new(user_params)
    elsif @type == 'MAUFan' || @type == 'User'
      attrs = user_params
      attrs[:login] = attrs[:login] || attrs[:email]
      MAUFan.new(attrs)
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

  def password_params
    k = user_params_key
    params.require(k).permit(:password, :password_confirmation)
  end

  def user_attrs
    (params[:artist] || params[:mau_fan] || params[:user] || {})
  end

  def user_params_key
    [:artist, :mau_fan, :user].detect{|k| params.has_key? k}
  end
    
  def user_params
    k = user_params_key
    attrs = user_attrs

    if params[:emailsettings]
      em = params[:emailsettings]
      em2 = {}
      em.each_pair do |k,v|
        em2[k] = ( v.to_i != 0 ? true : false)
      end
      attrs[:email_attrs] = em2.to_json
    end
    params.require(k).permit(:login, :email, :firstname, :lastname,
                             :password, :password_confirmation,
                             :url, :studio, :studio_id, :nomdeplume, :profile_image,
                             :email_attrs )
  end

end
