require File.dirname(__FILE__) + '/../test_helper'

class ArtistTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :users

  def test_should_create_artist
    assert_difference 'Artist.count' do
      artist = create_artist
      assert !artist.new_record?, "#{artist.errors.full_messages.to_sentence}"
      assert artist.errors.length == 0
    end
  end

  def test_should_require_login
    assert_no_difference 'Artist.count' do
      u = create_artist(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'Artist.count' do
      u = create_artist(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_lastname
    assert_no_difference 'Artist.count' do
      u = create_artist(:lastname => nil)
      assert u.errors.on(:lastname)
    end
  end

  def test_should_require_firstname
    assert_no_difference 'Artist.count' do
      u = create_artist(:firstname => nil)
      assert u.errors.on(:firstname)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'Artist.count' do
      u = create_artist(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'Artist.count' do
      u = create_artist(:email => nil)
      assert u.errors.on(:email)
    end
  end


  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = DateTime.now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at.utc.to_s, time.to_s
  end

  def test_should_remember_me_default_two_weeks
    before = DateTime.now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

protected
  def create_artist(options = {})
    record = Artist.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' , :firstname => 'first',
:lastname => 'last' }.merge(options))
    record.save
    record
  end
end
