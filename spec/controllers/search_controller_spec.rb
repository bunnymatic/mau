require 'rails_helper'

describe SearchController, elasticsearch: true do

  def letter_frequency(words)
    Hash.new(0).tap do |letters|
      [words].flatten.compact.join.downcase.gsub(/\s+/,'').each_char {|c| letters[c] += 1 }
    end.sort_by{|_letter, ct| ct}
  end

  let!(:studios) { FactoryGirl.create_list :studio, 4 }
  let!(:artists) {
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.first) +
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.last)
  }
  let(:media_search) { artists.map{|a| a.art_pieces.map(&:medium) }.flatten.compact[0..1] }
  let(:studios_search) { studios[0..1] }

  let(:studio_artist_name_match) do
    f = letter_frequency(studios_search.map(&:artists).flatten.map(&:full_name))
    f.last.first
  end

  before do
    stub_search_service!
  end

  describe "#index" do
    context "finding by studio" do
      before do
        get :index, params: { q: studios.first.name.split.first }
      end
      it 'returns success' do
        expect(response).to be_success
      end
    end
  end

end
