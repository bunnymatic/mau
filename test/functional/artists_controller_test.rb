require File.dirname(__FILE__) + '/../test_helper'
require 'artists_controller'

# Re-raise errors caught by the controller.
class ArtistsController; def rescue_action(e) raise e end; end

class ArtistsControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :artists

  def test_should_allow_signup
    assert_difference 'Artist.count' do
      create_artist
      assert_response :redirect
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:login => nil)
      assert assigns(:artist).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:password => nil)
      assert assigns(:artist).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:password_confirmation => nil)
      assert assigns(:artist).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'Artist.count' do
      create_artist(:email => nil)
      assert assigns(:artist).errors.on(:email)
      assert_response :success
    end
  end
  

  

  protected
    def create_artist(options = {})
      post :create, :artist => { :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
