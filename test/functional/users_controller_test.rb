require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def test_should_allow_fan_signup
    assert_difference 'User.count' do
      create_user
      assert !flash[:error]
      assert_response :redirect
    end
  end

  def test_should_not_count_fan_signup_as_artist
    assert_no_difference 'Artist.count' do
      create_user
      assert !flash[:error]
      assert_response :redirect
    end
  end

  def test_should_not_count_fan_in_studio0_artist_list
    s = Studio.indy.artists.count
    create_user
    assert !flash[:error]
    assert_response :redirect
    u = User.find_by_login('quire')
    u.state = 'active'
    u.save!
    s2 = Studio.indy.artists.count
    assert s2 == s
  end

  def test_should_allow_artist_signup
    assert_difference 'Artist.count' do
      create_artist
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'MAUFan.count' do
      create_user(:login => nil, :email => nil)
      assert assigns(:fan).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'MAUFan.count' do
      create_user(:password => nil)
      assert assigns(:fan).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'MAUFan.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:fan).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'MAUFan.count' do
      create_user(:email => nil)
      assert assigns(:fan).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_validate_login
    assert_no_difference 'MAUFan.count' do
      create_user(:login => "#$SGFCSR")
      assert assigns(:fan).errors.on(:login)
      assert_response :success
    end
    assert_no_difference 'MAUFan.count' do
      create_user(:login => "my name")
      assert assigns(:fan).errors.on(:login)
      assert_response :success
    end
  end
  
  def test_should_validate_email
    assert_no_difference 'MAUFan.count' do
      create_user(:email => 'bogus email address')
      assert assigns(:fan).errors.on(:email)
      assert_response :success
    end
    assert_no_difference 'MAUFan.count' do
      create_user(:email => 'noway@')
      assert assigns(:fan).errors.on(:email)
      assert_response :success
    end
    assert_no_difference 'MAUFan.count' do
      create_user(:email => '@nowhere.com')
      assert assigns(:fan).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_require_artist_login_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:login => nil)
      assert assigns(:artist).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_artist_password_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:password => nil)
      assert assigns(:artist).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_artist_password_confirmation_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:password_confirmation => nil)
      assert assigns(:artist).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_artist_email_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:email => nil)
      a = assigns(:artist)
      assert assigns(:artist).errors.on(:email)
      assert_response :success
    end
  end

 
  def test_should_validate_artist_login
    assert_no_difference 'Artist.count' do
      create_artist(:login => "#$SGFCSR")
      assert assigns(:artist).errors.on(:login)
      assert_response :success
    end
    assert_no_difference 'Artist.count' do
      create_artist(:login => "my name")
      assert assigns(:artist).errors.on(:login)
      assert_response :success
    end
  end
  
  def test_should_validate_artist_email
    assert_no_difference 'Artist.count' do
      create_artist(:email => 'bogus email address')
      assert assigns(:artist).errors.on(:email)
      assert_response :success
    end
    assert_no_difference 'Artist.count' do
      create_artist(:email => 'noway@')
      assert assigns(:artist).errors.on(:email)
      assert_response :success
    end
    assert_no_difference 'Artist.count' do
      create_artist(:email => '@nowhere.com')
      assert assigns(:artist).errors.on(:email)
      assert_response :success
    end
  end

  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', 
        :email => 'quire@example.com',
        :password => 'quire69', 
        :password_confirmation => 'quire69',
        :firstname => 'thefirstname',
      :lastname => 'thelastname' }.merge(options),
      :type => 'MAUFan'
    end
    def create_artist(options = {})
      post :create, :artist => { :login => 'quire', 
        :email => 'quire@example.com',
        :password => 'quire69', 
        :password_confirmation => 'quire69',
        :firstname => 'thefirstname',
      :lastname => 'thelastname' }.merge(options),
      :type => 'Artist'
    end

end
