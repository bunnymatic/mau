require 'rails_helper'

describe DenylistDomain do
  it 'downcases the domain' do
    DenylistDomain.create!(domain: 'MYUppercaseDomain.com')
    expect(DenylistDomain.find_by(domain: 'myuppercasedomain.com')).to be
  end

  it 'should create a new instance given valid attributes' do
    DenylistDomain.create! FactoryBot.attributes_for(:denylist_domain)
  end

  %w[valid.com a.valid.domain.biz].each do |domain|
    it "validates #{domain} as valid" do
      expect(DenylistDomain.new(domain: domain)).to be_valid
    end
  end

  %w[invalid whover.superlongtld a.b.c.e.f.g.h].each do |domain|
    it "validates #{domain} as invalid" do
      expect(DenylistDomain.new(domain: domain)).not_to be_valid
    end
  end

  describe '#allowed?' do
    before do
      FactoryBot.create(:denylist_domain, domain: 'denylist.com')
    end
    it 'finds denylist domains in email' do
      expect(DenylistDomain.allowed?('jon@denylist.com')).to eq false
    end
    it 'allows non denylisted email' do
      expect(DenylistDomain.allowed?('jon@notdenylist.com')).to eq(true)
    end
  end
end
