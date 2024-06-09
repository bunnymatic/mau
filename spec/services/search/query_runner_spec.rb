require 'rails_helper'

describe Search::QueryRunner do
  subject(:runner) { described_class.new(query) }
  let(:query) { 'looking for' }

  describe '.search' do
    let(:results) do
      {
        'took' => 7,
        'timed_out' => false,
        '_shards' => {
          'total' => 3,
          'successful' => 3,
          'skipped' => 0,
          'failed' => 0,
        },
        'hits' => {
          'total' => {
            'value' => 13,
            'relation' => 'eq',
          },
          'max_score' => 22.3708,
          'hits' => [
            {
              '_index' => 'artists',
              '_id' => '5',
              '_score' => 22.3708,
              '_source' => {
                'artist' => {
                  'firstname' => 'Jon',
                  'lastname' => 'Rogers',
                  'nomdeplume' => '',
                  'slug' => 'administrator',
                  'artist_name' => 'Jon Rogers',
                  'studio_name' => 'Runolfsson LLC1',
                  'bio' => " statement\r\nMy work explores stuff",
                  'os_participant' => true,
                  'images' => {
                    'small' => 'http://localhost:3000/rails/active_storage/representations/redirect/7eddcea/autobianchi-runabout.jpg',
                    'medium' => 'http://localhost:3000/rails/active_storage/representations/redirect/7ecea/autobianchi-runabout.jpg',
                    'large' => 'http://localhost:3000/rails/active_storage/representations/redirect/c9789f/autobianchi-runabout.jpg',
                    'original' => 'http://localhost:3000/rails/active_storage/representations/redirect/aabc/autobianchi-runabout.jpg',
                  },
                },
              },
            },
          ],
        },
      }
    end
    before do
      allow(Search::SearchService).to receive(:search).and_return(results)
    end

    it 'returns an array of SearchHits' do
      expect(runner.search).to eq [
        Search::SearchHit.new(results['hits']['hits'].first),
      ]
    end

    context 'when there are no hits' do
      let(:results) { {} }
      it 'returns nil' do
        expect(runner.search).to be_nil
      end
    end
  end
end
