require 'spec_helper'

module MAUFanSpecHelper
  def valid_user_attributes
    { :login => 'joe@bloggs.com',
      :email => "joe@bloggs.com",
      :password => "abcdefg",
      :password_confirmation => "abcdefg"
    }
  end
end

describe MAUFan do
  include MAUFanSpecHelper
  describe '#new' do
    
    it "should not be valid artist from blank new artist" do
      a = MAUFan.new
      a.should_not be_valid
      a.should have(2).error_on(:password)
      a.should have(1).error_on(:password_confirmation)
      a.should have_at_least(2).error_on(:login)
      a.should have(3).error_on(:email)
    end
    
    it "should be valid fan" do 
      a = MAUFan.new
      a.attributes = valid_user_attributes
      a.should be_valid
    end

    it "should be require password confirmation" do
      a = MAUFan.new
      a.attributes = valid_user_attributes.except(:password_confirmation)
      a.should have(1).error_on(:password_confirmation)
    end

    it "should not allow 'bogus email' for email address" do 
      a = MAUFan.new
      a.attributes = valid_user_attributes.except(:email)
      a.email = 'bogus email'
      a.should_not be_valid
      a.should have_at_least(1).error_on(:email)
    end

    it "should not allow '   ' for email" do 
      a = MAUFan.new
      a.attributes = valid_user_attributes.except(:email)
      a.email = '   '
      a.should_not be_valid
      a.should have_at_least(1).error_on(:email)
    end
    it "should not allow blow@ for email" do 
      a = MAUFan.new
      a.attributes = valid_user_attributes.except(:email)
      a.email = 'blow@'
      a.should_not be_valid
      a.should have_at_least(1).error_on(:email)
    end
  end
  
end
