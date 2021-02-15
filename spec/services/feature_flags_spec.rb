require 'rails_helper'

describe FeatureFlags do
  context 'when config.features.virtual_open_studios is false' do
    before do
      mock_app_config(:features, { virtual_open_studios: false })
    end
    it 'gets virtual open studios flag from config.features.virtual_open_studios' do
      expect(FeatureFlags.virtual_open_studios?).to eq false
    end
  end
  context 'when config.features.virtual_open_studios is true' do
    before do
      mock_app_config(:features, { virtual_open_studios: true })
    end
    it 'gets virtual open studios flag from config.features.virtual_open_studios' do
      expect(FeatureFlags.virtual_open_studios?).to eq true
    end
  end
end
