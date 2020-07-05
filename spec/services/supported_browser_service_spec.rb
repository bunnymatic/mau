# frozen_string_literal: true

require 'rails_helper'

describe SupportedBrowserService do
  describe "when we're not in test mode" do
    before do
      allow(Rails.env).to receive(:test?).and_return(false)
      allow(JSON).to receive(:parse).and_call_original
    end
    it 'returns the contents of the supported browser json' do
      expect(described_class.supported_browsers).to be_kind_of(Array)
      expect(described_class.supported_browsers).not_to be_empty
    end
    it 'memoizes the supported browser json' do
      described_class._reset
      described_class.supported_browsers
      described_class.supported_browsers
      described_class.supported_browsers

      expect(JSON).to have_received(:parse).once
    end
  end
end
