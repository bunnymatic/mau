require 'spec_helper'

describe BlacklistDomain do

  it "downcases the domain" do
    BlacklistDomain.create!(:domain => 'MYUppercaseDomain.com')
    BlacklistDomain.find_by_domain('myuppercasedomain.com').should be
  end

  it "should create a new instance given valid attributes" do
    BlacklistDomain.create! FactoryGirl.attributes_for(:blacklist_domain)
  end

  %w( valid.com a.valid.domain.biz ).each do |domain|
    it "validates #{domain} as valid" do
      BlacklistDomain.new(:domain => domain).should be_valid
    end
  end

  %w( invalid whover.superlongtld a.b.c.e.f.g.h ).each do |domain|
    it "validates #{domain} as invalid" do
      BlacklistDomain.new(:domain => domain).should_not be_valid
    end
  end

  describe '#is_allowed?' do
    before do
      FactoryGirl.create(:blacklist_domain, domain: "blacklist.com")
    end
    it 'finds blacklist domains in email' do
      BlacklistDomain::is_allowed?("jon@blacklist.com").should be_false
    end
    it 'allows non blacklisted email' do
      BlacklistDomain::is_allowed?("jon@notblacklist.com").should be_true
    end
  end
end
