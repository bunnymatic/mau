require 'opensearch'

module Search
  class OpenSearchClient
    def self.index(index, id, document)
      new.client.index(
        index:,
        id:,
        body: document,
        refresh: true,
      )
    end

    def self.delete(index, id)
      new.client.delete(
        index:,
        id:,
        ignore: 404,
      )
    rescue ::OpenSearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.update(index, id, document)
      new.client.update(
        index:,
        id:,
        body: { doc: document },
      )
    rescue ::OpenSearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.create_index(index, settings:, analysis:, mappings:)
      indices_client = new.client.indices

      indices_client.create(index:,
                            body: {
                              settings: {
                                **settings,
                                analysis:,
                              },
                              mappings: {
                                properties: mappings,
                              },
                            })
    end

    def self.delete_index(index)
      new.client.indices.delete(index:, ignore: 404)
    end

    def self.multi_index_search(indices, query_body)
      new.client.search(
        index: indices.join(','),
        body: query_body,
      )
    end

    def client
      client_params = {
        hosts: [Rails.application.config.opensearch_url],
      }
      @client ||= ::OpenSearch::Client.new(**client_params)
    end
  end
end
