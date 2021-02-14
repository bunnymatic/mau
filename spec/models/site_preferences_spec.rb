require 'rails_helper'

RSpec.describe SitePreferences, type: :model do
  describe '.instance' do
    it 'tries first then create' do
      allow(SitePreferences).to receive(:first)
      allow(SitePreferences).to receive(:create)
      SitePreferences.instance
      expect(SitePreferences).to have_received(:first)
      expect(SitePreferences).to have_received(:create)
    end

    it 'returns first if it exists' do
      create(:site_preferences)
      allow(SitePreferences).to receive(:create)
      SitePreferences.instance
      expect(SitePreferences).to_not have_received(:create)
    end

    context 'sending in `cached = true`' do
      it 'tries the cache first' do
        allow(SitePreferences).to receive(:first)
        allow(SitePreferences).to receive(:create)
        allow(SafeCache).to receive(:read).and_return(build_stubbed(:site_preferences).to_json)
        SitePreferences.instance(check_cache: true)
        expect(SitePreferences).to_not have_received(:first)
        expect(SitePreferences).to_not have_received(:create)
      end
    end
  end
end
