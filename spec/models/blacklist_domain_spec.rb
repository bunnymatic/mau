# frozen_string_literal: true
require 'rails_helper'

describe BlacklistDomain do
  it 'downcases the domain' do
    BlacklistDomain.create!(domain: 'MYUppercaseDomain.com')
    expect(BlacklistDomain.find_by_domain('myuppercasedomain.com')).to be
  end

  it 'should create a new instance given valid attributes' do
    BlacklistDomain.create! FactoryGirl.attributes_for(:blacklist_domain)
  end

  %w(valid.com a.valid.domain.biz).each do |domain|
    it "validates #{domain} as valid" do
      expect(BlacklistDomain.new(domain: domain)).to be_valid
    end
  end

  %w(invalid whover.superlongtld a.b.c.e.f.g.h).each do |domain|
    it "validates #{domain} as invalid" do
      expect(BlacklistDomain.new(domain: domain)).not_to be_valid
    end
  end

  describe '#is_allowed?' do
    before do
      FactoryGirl.create(:blacklist_domain, domain: 'blacklist.com')
    end
    it 'finds blacklist domains in email' do
      expect(BlacklistDomain.is_allowed?('jon@blacklist.com')).to eq false
    end
    it 'allows non blacklisted email' do
      expect(BlacklistDomain.is_allowed?('jon@notblacklist.com')).to eq(true)
    end
  end
end
