# frozen_string_literal: true

class UsersController < ApplicationController
  class UserNotFoundError < StandardError; end

  before_action :logged_out_required, only: [:new]
  before_action :admin_required, only: [:destroy]
  before_action :user_required, only: %i[edit update deactivate
                                         change_password_update]

  DEFAULT_ACCOUNT_TYPE = 'MauFan'

  def index
    redirect_to artists_path
  end

  def whoami
    ((render json: {}) && return) unless current_user
    render json: {
      current_user: {
        id: current_user&.id,
        login: current_user&.login,
        slug: current_user&.slug,
      },
    }
  end

  def edit
    @fan = safe_find_user(params[:id])

    if (@fan != current_user) || current_user.artist?
      flash.keep
      redirect_to edit_artist_path(current_user)
      return
    end
    @user = UserPresenter.new(current_user)
  end

  def show
    @fan = safe_find_user(params[:id])
    unless @fan&.active?
      flash.now[:error] = 'The account you were looking for was not found.'
      redirect_to(artists_path) && return
    end
    redirect_to(artist_path(@fan)) && return if @fan.artist?

    @page_title = PageInfoService.title(sprintf('Fan: %s', @fan.get_name(escape: true)))
    @fan = UserPresenter.new(@fan)
  end

  def new
    artist = Artist.new
    fan = MauFan.new
    @studios = StudioService.all
    type = params[:type] || user_attrs[:type]
    @type = %w[Artist MauFan].include?(type) ? type : 'Artist'
    @user = @type == 'MauFan' ? fan : artist
  end

  def update
    if commit_is_cancel
      redirect_to user_path(current_user)
      return
    end
    msg = {}
    if current_user.update(user_params)
      Messager.new.publish "/artists/#{current_user.id}/update", 'updated artist info'
      msg['notice'] = 'Your profile has been updated'
    else
      msg['error'] = ex.to_s
    end
    redirect_to edit_user_url(current_user), flash: msg
  end

  def create
    logout
    @type = params.delete(:type)
    @type ||= user_attrs[:type]

    @user = build_user_from_params
    recaptcha = true # && verify_recaptcha(model: @user, message: "You failed to prove that you're not a robot")
    secret = verify_secret_word(model: @user, message: "You don't seem to know the secret word.  Sorry.")
    @user.state = 'pending'
    redirect_after_create && return if secret && recaptcha && @user.save

    render_on_failed_create
  end

  # Change user passowrd
  def change_password_update
    msg = {}
    if current_user.valid_password? user_attrs['old_password']
      if current_user.update(password_params)
        msg[:notice] = 'Your password has been updated'
      else
        msg[:error] = current_user.errors.full_messages.to_sentence
      end
    else
      msg[:error] = 'Your old password was incorrect'
    end
    redirect_to edit_user_path(current_user, anchor: 'password'), flash: msg
  end

  def reset
    @user = User.find_by(reset_code: reset_code_from_params)

    if @user.nil?
      flash[:error] = 'Are you sure you got the right link -- maybe you should double check your email?'
      render_not_found UserNotFoundError.new('failed to find user with reset code')
      return
    end
    render && return unless request.post? && user_params

    if @user.update(user_params.slice(:password, :password_confirmation))
      @user.delete_reset_code
      flash[:notice] = "Password reset successfully for #{@user.email}.  Please log in."
      logout
      redirect_to login_path
      return
    end

    flash[:error] = 'Failed to update your password.'
    @user.password = ''
    @user.password_confirmation = ''
  end

  def destroy
    id = destroy_params[:id]
    u = safe_find_user(id)
    if u
      if u.id == current_user.id
        flash[:error] = "You can't delete yourself."
      else
        name = u.login
        u.delete!
        flash[:notice] = "The account for login #{name} has been deactivated."
      end
    else
      flash[:error] = "Couldn't find user #{id}"
    end
    redirect_to(users_path) && return
  end

  def activate
    logout
    code = activate_params[:activation_code]
    user = User.find_by(activation_code: code) if code.present?

    unless user
      flash[:error] = 'Are you sure you got the right link -- maybe you should double check your email?'\
                      " Or maybe you've already activated -- try signing in."
      redirect_to(login_path) && return
    end

    if code.present? && !user.active?
      user.activate!
      MailChimpService.new(user).subscribe_and_welcome
      flash[:notice] = "We're so excited to have you! Just sign in to get started."
    elsif code.blank?
      flash[:error] = 'Your activation code was missing.  Please follow the URL from your email.'
    end

    redirect_to login_path
  end

  def resend_activation
    render && return unless request.post?

    inputs = params.require(user_params_key).permit(:email)
    email = inputs[:email]
    if email.present?
      flash[:notice] = "We sent your activation code to #{email}. Please check your email for instructions."
      user = User.find_by(email: email)
      user&.resend_activation
      redirect_back_or_default('/')
    else
      flash[:error] = 'You need to enter an email'
    end
  end

  def forgot
    render && return unless request.post?

    inputs = params.require(user_params_key).permit(:email)
    user = User.find_by(email: inputs[:email])
    flash[:notice] = "We've sent email with instructions on how to reset your password."\
                     '  Please check your email.'
    if user
      if user.active?
        user.create_reset_code
      else
        flash[:notice] = nil
        flash[:error] = 'That account is not yet active.  Have you responded to the activation email we'\
                        ' already sent?  Enter your email below if you need us to send you a new activation email.'
      end
    end
    redirect_to login_path
  end

  def deactivate
    logout
    SuspendArtistService.new(current_user).suspend!
    flash[:notice] = 'Your account has been deactivated.'
    redirect_to root_path
  end

  protected

  def render_on_failed_create
    msg = [
      'There was a problem creating your account.',
      [@user.errors[:base]],
      ' Please correct these issues or contact us, if you continue to have problems.',
    ].flatten.join(' ')
    flash.now[:error] = msg.html_safe
    @studios = StudioService.all
    @user.valid?
    render 'new'
  end

  def redirect_after_create
    if @type == 'Artist'
      @user.reload
      @user.build_artist_info
      @user.artist_info.save!
      @user.save!
      Messager.new.publish '/artists/create', 'added a new artist'
      flash[:notice] = "We're so excited to have you! Just sign in to get started."
    else
      flash[:notice] = "Thanks for signing up!  Login and you're ready to roll!"
    end

    @user.activate!
    MailChimpService.new(@user).subscribe_and_welcome
    redirect_to login_path
  end

  def safe_find_user(id)
    User.friendly.find(id)
  rescue ActiveRecord::RecordNotFound
    flash.now[:error] = 'The user you were looking for was not found.'
    nil
  end

  private

  def build_user_from_params
    return if user_params.empty?

    case @type
    when 'Artist'
      Artist.new(user_params)
    when 'MauFan', 'User'
      attrs = user_params
      attrs[:login] = attrs[:login] || attrs[:email]
      MauFan.new(attrs)
    end
  end

  def basic_note_info_from_params
    # TODO: use strong params
    {}.tap do |info|
      %w[comment login email page name].each do |k|
        info[k] = params[k] if params.include? k
      end
    end
  end

  def scammer_emails
    @scammer_email ||=
      begin
        fixed_names = ['philipcolee@yahoo.com', 'evott@rocketmail.com', 'mrsute14@yahoo.com', 'garymartin@gmail.com]']
        Scammer.all.map(&:email) + fixed_names
      end
  end

  def build_note_info_from_params
    id = params[:id]
    note_info = basic_note_info_from_params
    if params.include? 'i_love_honey'
      # spammer hit the honey pot.
      note_info['artist_id'] = id
      note_info['reason'] = 'hit the honey pot'
    elsif scammer_emails.include? note_info['email']
      note_info['artist_id'] = id
      note_info['reason'] = 'matches suspect scammer email address'
    elsif /Morning,I would love to purchase/i.match?(note_info['comment']) || /\s+details..i/i.match?(note_info['comment'])
      note_info['artist_id'] = id
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
    %i[artist mau_fan user].detect { |k| params.key? k }
  end

  def destroy_params
    params.permit(:id)
  end

  def reset_code_from_params
    params.permit(:reset_code)[:reset_code]
  end

  def activate_params
    params.permit(:activation_code)
  end

  def user_params
    key = user_params_key
    permitted = %i[login email firstname lastname type
                   password password_confirmation
                   studio studio_id nomdeplume photo] + User.stored_attributes[:links]
    params.require(key).permit(*permitted)
  end

  def verify_secret_word(opts)
    valid = (params.delete(:secret_word) == Conf.signup_secret_word)
    opts[:model].errors.add(:base, opts[:message] || "You clearly don't have the secret password.") unless valid
    valid
  end
end
