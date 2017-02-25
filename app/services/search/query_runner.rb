# frozen_string_literal: true
module Search
  class QueryRunner
    def initialize(query = nil, _include_highlight = true)
      @query = query
    end

    def search
      t = Time.now.to_f
      return [] unless @query.present?
      results = multi_index_search
      package_results(results)
    end

    def multi_index_search
      query_body = {
        query: {
          multi_match: {
            query: @query,
            fields: ['_all', 'studio.name^5', 'artist.artist_name^5', 'art_piece.title^3', 'art_piece.artist_name^3'],
            type: 'most_fields',
            fuzziness: 1
          }
        },
        size: 100,
        highlight: {
          fields: {
            'name' => {},
            'tags' => {},
            'title' => {},
            'artist_name' => {},
            'artist_bio' => {},
            'bio' => {}
          }
        }
      }
      EsClient.client.search(
        index: [:art_pieces, :studios, :artists].join(','),
        body: query_body
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
