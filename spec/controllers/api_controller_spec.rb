require 'spec_helper'

describe ApiController do

  let(:studio) { FactoryGirl.create(:studio) }
  let(:artists) {
    FactoryGirl.create_list(:artist, 2, :with_art, studio: studio, number_of_art_pieces: 3) +
      FactoryGirl.create_list(:artist, 2, :with_art, number_of_art_pieces: 3) +
        FactoryGirl.create_list(:artist, 2, :with_art, state: 'suspended')
  }
  let(:art_pieces) { artists.map(&:art_pieces).flatten }
  let(:art_piece) { art_pieces.first }
  let(:artist) { artists.first }

  shared_examples_for 'all responses' do
    it { expect(response).to be_json }
  end
  shared_examples_for 'good responses' do
    it_should_behave_like 'all responses'
    it 'returns success' do
      expect(response).to be_success
    end
  end
  shared_examples_for 'error responses' do
    it_should_behave_like 'all responses'
    it 'returns status 400' do
      expect(response.code).to eql '400'
    end
    it 'returns a message in the json response' do
      expect(JSON.parse(response.body)).to have_key 'message'
    end
    it 'returns ApiError in the message' do
      resp = JSON.parse(response.body)
      expect(resp).to have_key 'message'
      expect(resp['message']).to match /ApiError/
    end
    it 'returns status in the json response' do
      resp = JSON.parse(response.body)
      expect(resp).to have_key 'status'
      expect(resp['status'].to_s).to eql response.code
    end
  end

  before do
    fix_leaky_fixtures
  end

  context 'bad requests' do
    [['bogus'], ['bogus',1],
     ['artists','b','c','d'],  ['artists','2','edit'],
     ['hash']].each do |params_path|
      context "given #{params_path.inspect} as input parameters" do
        before do
          get :index, :path => params_path
        end
        it_should_behave_like 'error responses'
      end
    end
    [ 'artists', 'studios', 'art_pieces' ].each do |typ|
      it 'reports unable to find ApiError given an object type that is valid but not queryable' do
        get :index, :path => [typ, 4]
        expect(JSON.parse(response.body)['message']).to match 'Unable to find the record'
        expect(JSON.parse(response.body)['message']).to match typ
      end
    end
    context "given a studio destroy path as input parameters" do
      before do
        get :index, :path => ['studios',studio.id,'destroy']
      end
      it_should_behave_like 'error responses'
    end
  end

  context 'given [media] as input params' do
    before do
      get :index, :path => ['media']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of media' do
      expect(@resp).to be_a_kind_of Array
      expect(@resp.count).to eql Medium.count
      expect(@resp.all? {|a| a.has_key? 'medium'}).to eq true, 'All items do not have the "name" key'
    end
  end

  context 'given [artists] as input parameters' do
    before do
      get :index, :path => ['artists']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of active artists' do
      expect(@resp).to be_a_kind_of Array
      expect(@resp.count).to eql Artist.active.count
      expect(@resp.all? {|a| a.has_key? 'artist'}).to eq true, 'All items do not have the "artist" key'
    end
  end

  context 'given [artists, artist_id] as input parameters' do
    before do
      get :index, :path => ['artists', artist.id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the artist we asked for' do
      expect(@resp).to be_a_kind_of Hash
      expect(@resp['artist']).to be_a_kind_of Hash
      expect(@resp['artist']['id']).to eql artist.id
      expect(@resp['artist']['firstname']).to eql artist.firstname
    end
  end

  context 'given [studios] as input parameters' do
    before do
      artists
      get :index, :path => ['studios']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of studios' do
      expect(@resp).to be_a_kind_of Array
      expect(@resp.count).to eql Studio.count
      expect(@resp.all? {|s| s.has_key? 'studio'}).to eq true, 'All items do not have the "studio" key'
    end
  end

  context 'given [studios, studio_id] as input parameters' do
    before do
      studio
      get :index, :path => ['studios', studio.id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the studio we asked for' do
      expect(@resp).to be_a_kind_of Hash
      expect(@resp['studio']).to be_a_kind_of Hash
      expect(@resp['studio']['id']).to eql studio.id
      expect(@resp['studio']['name']).to eql studio.name
    end
  end

  context 'given /studios/studio_id as the path' do
    before do
      studio
      get :index, :path => "studios/#{studio.id}"
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the studio we asked for' do
      expect(@resp).to be_a_kind_of Hash
      expect(@resp['studio']).to be_a_kind_of Hash
      expect(@resp['studio']['id']).to eql studio.id
      expect(@resp['studio']['name']).to eql studio.name
    end
  end

  context 'given [art_pieces] as input parameters' do
    before do
      artists
      get :index, :path => ['art_pieces']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of art_pieces' do
      expect(@resp).to be_a_kind_of Array
      expect(@resp.count).to eql 12
      expect(@resp.all? {|s| s.has_key? 'art_piece'}).to eq true, 'All items do not have the "art_piece" key'
    end
  end

  context 'given [art_pieces, art_piece_id] as input parameters' do
    before do
      get :index, :path => ['art_pieces', art_piece.id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the art_piece we asked for' do
      expect(@resp).to be_a_kind_of Hash
      expect(@resp['art_piece']).to be_a_kind_of Hash
      expect(@resp['art_piece']['id']).to eql art_piece.id
      expect(@resp['art_piece']['title']).to eql art_piece.title
    end
  end

  context 'given art_pieces, ids as input params' do
    before do
      artists
      get :index, :path => ['art_pieces', 'ids']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the all art piece ids' do
      expect(@resp).to be_a_kind_of Array
      expect(@resp.count).to eql 12
    end
  end

  context 'get parameter from object' do
    before do
      studio
      get :index, :path => ['studios', studio.id.to_s, 'name']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns only the studio name' do
      expect(@resp.keys).to include 'name'
      expect(@resp).to eql({'name' => studio.name})
    end
  end

  context 'get art piece of an inactive artist' do
    before do
      artists
      inactive = (Artist.all - Artist.active).last
      get :index, :path => ['art_pieces', inactive.art_pieces.first.id]
    end
    it_should_behave_like 'error responses'
  end

end
