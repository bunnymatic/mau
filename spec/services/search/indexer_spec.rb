require 'rails_helper'

describe Search::Indexer do

  describe Search::Indexer::ObjectSearchService, elasticsearch: true do

    let(:model) { create :artist }
    subject(:service) { described_class.new(model) }

    it "reindexes successfully even if the item is not in the bucket" do
      expect {
        subject.reindex
      }.not_to raise_error
    end
  end

end
