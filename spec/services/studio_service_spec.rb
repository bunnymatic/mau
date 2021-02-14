require 'rails_helper'

describe StudioService do
  describe '.all_studios' do
    it 'returns all real studios with more than Config.min_aritsts_per_studio order by position' do
      create_list(:studio, 2, :with_artists)
      create(:studio)
      studios = described_class.all_studios
      expect(studios.size).to eq(2)
      expect(studios.map(&:id)).to_not include 0
      expect(studios.map(&:id)).to_not include nil
      expect(studios.map(&:position)).to be_monotonically_increasing
    end
  end
end
