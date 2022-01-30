require 'rails_helper'

describe CatalogsController do
  let(:catalog_presenter_methods) do
    { csv: "a,b,c\n1,2,3", csv_filename: 'the filename' }
  end

  let(:mock_catalog_presenter) do
    instance_double(CatalogPresenter, catalog_presenter_methods)
  end

  before do
    allow(CatalogPresenter).to receive(:new).and_return(mock_catalog_presenter)
  end

  describe '#show' do
    let(:catalog) { assigns(:catalog) }
    context 'format=html' do
      before do
        get :show
      end
      it { expect(response).to be_successful }
    end

    context 'format=csv' do
      render_views
      let(:parse_args) { ViewPresenter::DEFAULT_CSV_OPTS.merge(headers: true) }
      let(:parsed) { CSV.parse(response.body, **parse_args) }

      before do
        get :show, format: :csv
      end
      it { expect(response).to be_successful }
      it { expect(response).to be_csv_type }
      it 'includes the right headers' do
        expect(parsed.headers).to eq(%w[a b c])
      end

      it 'includes the right data' do
        expect(parsed.size).to eq(1)
        row = parsed.first.to_h
        expect(row).to eq('a' => '1', 'b' => '2', 'c' => '3')
      end
    end
  end

  describe '#social' do
    before do
      allow(SocialCatalogPresenter).to receive(:new).and_return(mock_catalog_presenter)
    end
    context 'format=html' do
      before do
        get :social
      end
      it { expect(response).to be_successful }
    end
    context 'format=csv' do
      let(:parse_args) { ViewPresenter::DEFAULT_CSV_OPTS.merge(headers: true) }
      let(:parsed) { CSV.parse(response.body, **parse_args) }
      let(:social_keys) { SocialCatalogPresenter::SOCIAL_KEYS }
      before do
        get :social, format: :csv
      end
      it { expect(response).to be_successful }
      it { expect(response).to be_csv_type }

      it 'includes the right headers' do
        expect(parsed.headers).to eq(%w[a b c])
      end

      it 'includes the right data' do
        expect(parsed.size).to eq(1)
        row = parsed.first.to_h
        expect(row).to eq('a' => '1', 'b' => '2', 'c' => '3')
      end
    end
  end
end
