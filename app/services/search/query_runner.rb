# frozen_string_literal: true

module Search
  class QueryRunner
    def initialize(query = nil, _include_highlight: true)
      @query = query
    end

    def search
      return [] if @query.blank?

      results = multi_index_search
      package_results(results)
    end

    def multi_index_search
      query_body = {
        query: {
          multi_match: {
            query: @query,
            fields: [
              'studio.name^5',
              'artist.artist_name^5',
              'art_piece.title^5',
              'art_piece.title_ngram^3',
              'art_piece.artist_name^3',
              'artist.firstname',
              'artist.lastname',
              'art_piece.medium',
              'art_piece.tags',
            ],
            type: 'most_fields',
            fuzziness: 0,
          },
        },
        size: 100,
        # highlight: {
        #   fields: {
        #     'studio.name' => {},
        #     'artist.artist_name' => {},
        #     'art_piece.title' => {},
        #     'art_piece.tags' => {},
        #     'art_piece.medium' => {},
        #     'art_piece.title' => {},
        #     'artist.artist_name' => {},
        #   },
        # },
      }
      EsClient.client.search(
        index: %i[art_pieces studios artists].join(','),
        body: query_body,
      )
    end

    def package_results(raw_results)
      return unless raw_results.key?('hits') && raw_results['hits'].key?('hits')

      raw_results['hits']['hits'].map do |hit|
        highlights = hit['highlight'] || {}
        highlights.each do |full_field, value|
          field1, field2 = full_field.split('.')
          hit['_source'][field1][field2] = value if [field1, field2, value].all?(&:present?)
        end
        OpenStruct.new(hit)
      end
    end

    delegate :client, to: :es, prefix: true
  end
end
