class UsersController < ApplicationController

  before_action :logged_out_required, :only => [:new]
  before_action :admin_required, :only => [ :destroy ]
  before_action :user_required, :only => [ :edit, :update, :suspend, :deactivate,
                                           :change_password_update]


  DEFAULT_ACCOUNT_TYPE = 'MauFan'

  def index
    redirect_to artists_path
  end

  def whoami
    render json: { current_user: current_user.try(:login) }
  end

  def edit
    @fan = safe_find_user(params[:id])

    if (@fan != current_user) || current_user.is_artist?
      flash.keep
      redirect_to edit_artist_path(current_user)
      return
    end
    @user = UserPresenter.new(current_user)
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
    @fan = UserPresenter.new(@fan)
  end

  def new
    artist = Artist.new
    fan = MauFan.new
    @studios = StudioService.all
    type = params[:type] || user_attrs[:type]
    @type = ['Artist','MauFan'].include?(type) ? type : 'Artist'
    @user = (@type == 'MauFan') ? fan : artist
  end


  def update
    if commit_is_cancel
      redirect_to user_path(current_user)
      return
    end
    # clean os from radio buttons
    msg = {}
    if current_user.update_attributes(user_params)
      Messager.new.publish "/artists/#{current_user.id}/update", "updated artist info"
      msg["notice"] = "Your profile has been updated"
    else
      msg["error"] = ex.to_s
    end
    redirect_to edit_user_url(current_user), flash: msg
  end

  def create
    logout
    @type = params.delete(:type)
    @type ||= user_attrs[:type]

    # validate email domain
    @user = build_user_from_params
    recaptcha = verify_recaptcha(model: @user, message: "You failed to prove that you're not a robot")
    secret = verify_secret_word(model: @user, message: "You don't seem to know the secret word.  Sorry.")
    if secret && recaptcha && @user.save
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
        msg[:error] = current_user.errors.full_messages.to_sentence
      end
    else
      msg[:error] = "Your old password was incorrect"
    end
    redirect_to edit_user_path(current_user, anchor: 'password'), flash: msg
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
    id = destroy_params[:id]
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
    code = activate_params[:activation_code]
    user = User.find_by(activation_code: code) if code.present?

    if !user
      flash[:error]  = "We couldn't find an artist with that activation code -- check your email?"+
                       " Or maybe you've already activated -- try signing in."
      redirect_to login_path and return
    end

    if code.present? && !user.active?
      user.activate!
      MailChimpService.new(user).subscribe_and_welcome
      flash[:notice] = "We're so excited to have you! Just sign in to get started."
    elsif code.blank?
      flash[:error] = "Your activation code was missing.  Please follow the URL from your email."
    end

    redirect_to login_path
  end

  def resend_activation
    if request.post?
      inputs = params.require(user_params_key).permit(:email)
      email = inputs[:email]
      if email.present?
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
    render and return unless request.post?
    inputs = params.require(user_params_key).permit(:email)
    user = User.find_by_email(inputs[:email])
    flash[:notice] = "We've sent email with instructions on how to reset your password."+
                     "  Please check your email."
    if user
      if !user.active?
        flash[:notice] = nil
        flash[:error] = "That account is not yet active.  Have you responded to the activation email we"+
                        " already sent?  Enter your email below if you need us to send you a new activation email."
      else
        user.create_reset_code
      end
    end
    redirect_to login_path
  end

  def deactivate
    logout
    SuspendArtistService.new(current_user).suspend!
    flash[:notice] = "Your account has been deactivated."
    redirect_to root_path
  end

  protected
  def render_on_failed_create
    msg = [
      "There was a problem creating your account.",
      [@user.errors[:base]],
      " Please correct these issues or contact the webmaster (link below), if you continue to have problems."
    ].flatten.join("<br/>")
    flash.now[:error] = msg.html_safe
    @studios = StudioService.all
    @user.valid?
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
      MailChimpService.new(@user).subscribe_and_welcome
      flash[:notice] = "Thanks for signing up!  Login and you're ready to roll!"
      redirect_to login_path
    end
  end

  def safe_find_user(id)
    begin
      User.friendly.find(id)
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
    elsif @type == 'MauFan' || @type == 'User'
      attrs = user_params
      attrs[:login] = attrs[:login] || attrs[:email]
      MauFan.new(attrs)
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

  def destroy_params
    params.permit(:id)
  end

  def activate_params
    params.permit(:activation_code)
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
    permitted = [:login, :email, :firstname, :lastname, :type,
                 :password, :password_confirmation,
                 :studio, :studio_id, :nomdeplume, :photo,
                 :email_attrs] + User.stored_attributes[:links]
    params.require(k).permit(*permitted)
  end

  def verify_secret_word(opts)
    valid = (params.delete(:secret_word) == Conf.signup_secret_word)
    opts[:model].errors.add(:base, opts[:message] || "You clearly don't have the secret password.") unless valid
    valid
  end

end
