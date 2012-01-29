require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Email do
  describe 'validate' do
    ['this', 'that', 's pa c e d @ out.com', '@example.com'].each do |email|
      it "reports that '#{email}' is not valid" do
        Email.new(:email => email).should_not be_valid
      end
    end
    ['jo@example.com', 'this_dude+1@super.duper.google.com'].each do |email|
      it "reports that '#{email}' is valid" do
        Email.new(:email => email).should be_valid
      end
    end
  end
  
end
