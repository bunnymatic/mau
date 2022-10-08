require 'rails_helper'

describe OpenStudiosCatalogArtistsPaginator do
  let(:artists) do
    [
      build_stubbed(:artist),
      build_stubbed(:artist),
      build_stubbed(:artist),
    ]
  end
  let(:current_id) { nil }
  let(:paginator) { described_class.new(artists, current_id) }

  context 'when there is no current id' do
    it 'previous returns the last item' do
      expect(paginator.previous).to eq artists[2]
    end
    it 'next returns the first item' do
      expect(paginator.next).to eq artists[0]
    end
  end

  context 'when there is a current id' do
    let(:current_id) { artists[1].id }
    it 'previous returns the previous item' do
      expect(paginator.previous).to eq artists[0]
    end
    it 'next returns the next item' do
      expect(paginator.next).to eq artists[2]
    end
  end

  context 'when current is the first item' do
    let(:current_id) { artists[0].id }
    it 'previous returns the last item' do
      expect(paginator.previous).to eq artists[2]
    end
    it 'next returns the next item' do
      expect(paginator.next).to eq artists[1]
    end
  end

  context 'when current is the last item' do
    let(:current_id) { artists[2].id }
    it 'previous returns the previous item' do
      expect(paginator.previous).to eq artists[1]
    end
    it 'next returns the first item' do
      expect(paginator.next).to eq artists[0]
    end
  end

  context "when the current id doesn't match anything" do
    let(:current_id) { 120_000 }
    it 'previous returns the last item' do
      expect(paginator.previous).to eq artists[2]
    end
    it 'next returns the first item' do
      expect(paginator.next).to eq artists[0]
    end
  end
end
