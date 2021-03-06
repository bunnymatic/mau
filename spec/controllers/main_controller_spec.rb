require 'rails_helper'

describe MainController do
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:editor) { FactoryBot.create(:artist, :active, :editor) }
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:prolific_artist) { FactoryBot.create(:artist, :active, :with_art, number_of_art_pieces: 15) }

  before do
    # seems like we have leaky database records
    artist
    prolific_artist
    FactoryBot.create(:open_studios_event, :future)
  end

  describe '#index' do
    context 'not logged in' do
      before do
        get :index
      end
      it { expect(response).to be_successful }
    end
  end

  describe '#news' do
    before do
      get :resources
    end
    it { expect(response).to be_successful }
  end

  describe '#about' do
    context 'while not logged in' do
      before do
        FactoryBot.create(:cms_document, page: :main, section: :about)
        get :about
      end
      it { expect(response).to be_successful }
      it 'fetches markdown content' do
        expect(assigns(:content)).to have_key :content
        expect(assigns(:content)).to have_key :cmsid
      end
    end
  end

  describe '#privacy' do
    before do
      get :privacy
    end
    it { expect(response).to be_successful }
  end

  describe '#main/venues' do
    context 'while not logged in' do
      before do
        get :venues
      end
      it { expect(response).to be_successful }
    end
    context 'logged in as admin' do
      let(:venue_doc) do
        FactoryBot.create(:cms_document,
                          page: :venues,
                          section: :all,
                          article: "# these \n\n## are \n\n### venues \n\n* one\n* two\n* three")
      end
      before do
        venue_doc
        login_as(admin)
        get :venues
      end
    end
  end

  describe 'status', vcr: { cassette_name: 'server_status', record: :none } do
    it 'returns success' do
      get :status_page
      expect(response).to be_successful
    end
    it 'returns the server status' do
      get :status_page
      status = {
        version: Mau::Version::VERSION,
        main: true,
        elasticsearch: true,
      }
      expect(JSON.parse(response.body)).to eq status.with_indifferent_access
    end
  end

  describe 'version' do
    it 'returns the app version' do
      get :version
      expect(response.body).to eql Mau::Version.new.to_s
    end
  end

  describe 'sampler' do
    before do
      get :sampler
    end

    it 'renders the thumbs partial' do
      expect(response).to render_template 'main/_sampler_thumb'
    end
  end
end
