require 'rails_helper'

describe Search::OpenSearchClient do
  let(:mock_client_indices) do
    instance_double(OpenSearch::API::Indices::Actions,
                    {
                      create: true,
                      delete: true,
                      close: true,
                      open: true,
                      put_settings: true,
                      put_mapping: true,
                      exists?: true,
                    })
  end

  let(:mock_client) do
    instance_double(OpenSearch::Client,
                    {
                      index: true,
                      delete: true,
                      update: true,
                      search: true,
                      indices: mock_client_indices,
                    })
  end

  let(:index) { 'the-index' }
  let(:id) { 5 }
  let(:document) { { whatever: { name: 'a dummy document', id: } } }
  let(:settings) do
    {
      max_ngram_diff: 4,
      number_of_shards: 1,
      number_of_replicas: 0,
      blocks: {
        read_only_allow_delete: 'false',
      },
    }
  end
  let(:analysis) do
    {
      analyzer: {
        my_analyzer: {
          tokenizer: :my_tokenizer,
        },
      },
      tokenizer: {
        my_tokenizer: {
          type: 'ngram',
        },
      },
    }
  end
  let(:mappings) do
    {
      my_object: {
        my_field: { type: 'text', analyzer: :my_analyzer },
        other_field: { type: 'text', index: false },
      },
    }
  end

  before do
    allow(OpenSearch::Client).to receive(:new).and_return(mock_client)
  end

  describe '.index' do
    it 'indexes the document' do
      described_class.index(index, id, document)
      expect(mock_client).to have_received(:index).with(index:, id:, body: document, refresh: true)
    end
  end

  describe '.delete' do
    it 'deletes the document' do
      described_class.delete(index, id)
      expect(mock_client).to have_received(:delete).with(index:, id:, ignore: 404)
    end
  end
  describe '.update' do
    it 'updates the document' do
      described_class.update(index, id, document)
      expect(mock_client).to have_received(:update).with(
        index:, id:, body: { doc: document },
      )
    end
    context 'if the client update raises not found error' do
      before do
        allow(mock_client).to receive(:update).and_raise(OpenSearch::Transport::Transport::Errors::NotFound, 'crap')
      end
      it 'ignores' do
        expect do
          described_class.update(index, id, document)
        end.not_to raise_error
        expect(mock_client).to have_received(:update).with(
          index:, id:, body: { doc: document },
        )
      end
    end
  end
  describe '.create_index' do
    it 'creates an index with settings' do
      described_class.create_index(index,
                                   settings:,
                                   analysis:,
                                   mappings:)
      expect(mock_client_indices).to have_received(:create).with(
        index:,
        body: {
          mappings: {
            properties: mappings,
          },
          settings: {
            **settings,
            analysis:,
          },
        },
      )
    end
  end
  describe '.delete_index' do
    it 'deletes an index' do
      described_class.delete_index(index)
      expect(mock_client_indices).to have_received(:delete).with(
        index:, ignore: 404,
      )
    end
  end

  describe '.multi_index_search' do
    it 'searches multiple indexes' do
      described_class.multi_index_search(%w[stuffs haystacks], 'needle')
      expect(mock_client).to have_received(:search).with(
        index: 'stuffs,haystacks',
        body: 'needle',
      )
    end
  end
end
