require 'spec_helper'

describe ApiController do
  fixtures :users, :artist_infos, :studios, :art_pieces, :media, :art_piece_tags

  shared_examples_for 'all responses' do
    it 'returns json' do
      response.content_type.should == 'application/json'
    end
  end
  shared_examples_for 'good responses' do
    it_should_behave_like 'all responses'
    it 'returns success' do
      response.should be_success
    end
  end
  shared_examples_for 'error responses' do
    it_should_behave_like 'all responses'
    it 'returns status 400' do
      response.code.should == '400'
    end
    it 'returns a message in the json response' do
      JSON.parse(response.body).should have_key 'message'
    end
    it 'returns ApiError in the message' do
      resp = JSON.parse(response.body)
      resp.should have_key 'message'
      resp['message'].should match /ApiError/
    end
    it 'returns status in the json response' do
      resp = JSON.parse(response.body)
      resp.should have_key 'status'
      resp['status'].to_s.should eql response.code
    end
  end
      
  context 'bad requests' do
    [nil, ['bogus'], ['bogus',1], ['a','b','c','d'], ['artists','2','edit'], ['hash']].each do |params_path| 
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
        JSON.parse(response.body)['message'].should match 'Unable to find the record'
        JSON.parse(response.body)['message'].should match typ
      end
    end
  end

  context 'given [media] as input params' do
    before do
      get :index, :path => ['media']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of media' do
      @resp.should be_a_kind_of Array
      @resp.count.should == Medium.count
      @resp.all? {|a| a.has_key? 'medium'}.should be_true, 'All items do not have the "name" key'
    end
  end

  context 'given [artists] as input parameters' do
    before do
      get :index, :path => ['artists']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of active artists' do
      @resp.should be_a_kind_of Array
      @resp.count.should == Artist.active.count
      @resp.all? {|a| a.has_key? 'artist'}.should be_true, 'All items do not have the "artist" key'
    end
  end

  context 'given [artists, artist_id] as input parameters' do
    before do
      get :index, :path => ['artists', users(:jesseponce).id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the artist we asked for' do
      @resp.should be_a_kind_of Hash
      @resp['artist'].should be_a_kind_of Hash
      @resp['artist']['id'].should == users(:jesseponce).id
      @resp['artist']['firstname'].should == users(:jesseponce).firstname
    end
  end

  context 'given [studios] as input parameters' do
    before do
      get :index, :path => ['studios']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of studios' do
      @resp.should be_a_kind_of Array
      @resp.count.should == Studio.count + 1 # add 1 for indy
      @resp.all? {|s| s.has_key? 'studio'}.should be_true, 'All items do not have the "studio" key'
    end
  end

  context 'given [studios, studio_id] as input parameters' do
    before do
      get :index, :path => ['studios', studios(:s1890).id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the studio we asked for' do
      @resp.should be_a_kind_of Hash
      @resp['studio'].should be_a_kind_of Hash
      @resp['studio']['id'].should == studios(:s1890).id
      @resp['studio']['name'].should == studios(:s1890).name
    end
  end

  context 'given [art_pieces] as input parameters' do
    before do
      get :index, :path => ['art_pieces']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns a list of art_pieces' do
      @resp.should be_a_kind_of Array
      @resp.count.should == ArtPiece.count
      @resp.all? {|s| s.has_key? 'art_piece'}.should be_true, 'All items do not have the "art_piece" key'
    end
  end

  context 'given [art_pieces, art_piece_id] as input parameters' do
    before do
      get :index, :path => ['art_pieces', art_pieces(:hot).id]
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the art_piece we asked for' do
      @resp.should be_a_kind_of Hash
      @resp['art_piece'].should be_a_kind_of Hash
      @resp['art_piece']['id'].should == art_pieces(:hot).id
      @resp['art_piece']['title'].should == art_pieces(:hot).title
    end
  end

  context 'given art_pieces, ids as input params' do
    before do
      get :index, :path => ['art_pieces', 'ids']
      @resp = JSON.parse(response.body)
    end
    it_should_behave_like 'good responses'
    it 'returns the all art piece ids' do
      @resp.should be_a_kind_of Array
      @resp.count.should == ArtPiece.count
    end
  end
end
