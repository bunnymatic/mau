# frozen_string_literal: true
require 'rails_helper'

describe StudioService do
  subject(:service) { StudioService }
  describe ".all_studios" do
    let(:studios) { service.all_studios }
    before do
      create_list(:studio, 2, :with_artists) + [create(:studio)]
    end

    it "returns all studios with more than Config.min_aritsts_per_studio" do
      expect(studios.size).to eq(2)
    end

    it "does not include independent studio" do
      expect(studios.map(&:id)).to_not include 0
      expect(studios.map(&:id)).to_not include nil
    end

    context "when they've been ordered" do
      it "returns studios in order by position" do
        expect(studios.map(&:position)).to be_monotonically_increasing
      end
    end
  end
end
