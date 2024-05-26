# Licensed to OpenSearch B.V. under one or more contributor
# license agreements. See the NOTICE file distributed with
# this work for additional information regarding copyright
# ownership. OpenSearch B.V. licenses this file to you under
# the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# encoding: utf-8

module OpenSearch
  module Extensions
    # This module allows copying documents from one index/cluster to another one
    #
    # When required together with the client, it will add the `reindex` method
    #
    # @see Reindex::Reindex.initialize
    # @see Reindex::Reindex#perform
    #
    # @see http://www.rubydoc.info/gems/elasticsearch-api/OpenSearch/API/Actions#reindex-instance_method
    #
    module Reindex
      # Initialize a new instance of the Reindex class (shortcut)
      #
      # @see Reindex::Reindex.initialize
      #
      def new(arguments = {})
        Reindex.new(arguments)
      end; extend self

      module API
        # Copy documents from one index into another and refresh the destination index
        #
        # @example
        #     client.reindex source: { index: 'test1' }, dest: { index: 'test2' }, refresh: true
        #
        # The method allows all the options as {Reindex::Reindex.new}.
        #
        # This method will be mixed into the OpenSearch client's API, if available.
        #
        def reindex(arguments = {})
          arguments[:source] ||= {}
          arguments[:source][:client] = self
          Reindex.new(arguments).perform
        end
      end

      # Include the `reindex` method in the API and client, if available
      OpenSearch::API::Actions.include API if defined?(OpenSearch::API::Actions)
      OpenSearch::Transport::Client.include API if defined?(OpenSearch::Transport::Client) && defined?(OpenSearch::API)

      # Copy documents from one index into another
      #
      # @example Copy documents to another index
      #
      #   client  = OpenSearch::Client.new
      #   reindex = OpenSearch::Extensions::Reindex.new \
      #               source: { index: 'test1', client: client },
      #               dest: { index: 'test2' }
      #
      #   reindex.perform
      #
      # @example Copy documents to a different cluster
      #
      #     source_client  = OpenSearch::Client.new url: 'http://localhost:9200'
      #     destination_client  = OpenSearch::Client.new url: 'http://localhost:9250'
      #
      #     reindex = OpenSearch::Extensions::Reindex.new \
      #                 source: { index: 'test', client: source_client },
      #                 dest: { index: 'test', client: destination_client }
      #     reindex.perform
      #
      # @example Transform the documents during re-indexing
      #
      #     reindex = OpenSearch::Extensions::Reindex.new \
      #                 source: { index: 'test1', client: client },
      #                 dest: { index: 'test2' },
      #                 transform: lambda { |doc| doc['_source']['category'].upcase! }
      #
      #
      # The reindexing process works by "scrolling" an index and sending
      # batches via the "Bulk" API to the destination index/cluster
      #
      # @option arguments [String] :source The source index/cluster definition (*Required*)
      # @option arguments [String] :dest The destination index/cluster definition (*Required*)
      # @option arguments [Proc] :transform A block which will be executed for each document
      # @option arguments [Integer] :batch_size The size of the batch for scroll operation (Default: 1000)
      # @option arguments [String] :scroll The timeout for the scroll operation (Default: 5min)
      # @option arguments [Boolean] :refresh Whether to refresh the destination index after
      #                                      the operation is completed (Default: false)
      #
      # Be aware, that if you want to change the destination index settings and/or mappings,
      # you have to do so in advance by using the "Indices Create" API.
      #
      # Note, that there is a native "Reindex" API in OpenSearch 2.3.x and higer versions,
      # which will be more performant than the Ruby version.
      #
      # @see http://www.rubydoc.info/gems/elasticsearch-api/OpenSearch/API/Actions#reindex-instance_method
      #
      class Reindex
        attr_reader :arguments

        def initialize(arguments = {})
          [
            %i[source index],
            %i[source client],
            %i[dest index],
          ].each do |required_option|
            value = required_option.reduce(arguments) { |sum, o| sum[o] || {} }

            if value.respond_to?(:empty?) ? value.empty? : value.nil?
              raise ArgumentError,
                    "Required argument '#{Hash[*required_option]}' missing"
            end
          end

          @arguments = {
            batch_size: 1000,
            scroll: '5m',
            refresh: false,
          }.merge(arguments)

          arguments[:dest][:client] ||= arguments[:source][:client]
        end

        # Performs the operation
        #
        # @return [Hash] A Hash with the information about the operation outcome
        #
        def perform
          output = { errors: 0 }

          response = arguments[:source][:client].search(
            index: arguments[:source][:index],
            scroll: arguments[:scroll],
            size: arguments[:batch_size],
          )

          documents = response['hits']['hits']

          unless documents.empty?
            bulk_response = __store_batch(documents)
            output[:errors] += bulk_response['items'].count { |k, _v| k.values.first['error'] }
          end

          while (response = arguments[:source][:client].scroll(scroll_id: response['_scroll_id'], scroll: arguments[:scroll]))
            documents = response['hits']['hits']
            break if documents.empty?

            bulk_response = __store_batch(documents)
            output[:errors] += bulk_response['items'].count { |k, _v| k.values.first['error'] }
          end

          arguments[:dest][:client].indices.refresh index: arguments[:dest][:index] if arguments[:refresh]

          output
        end

        def __store_batch(documents)
          body = documents.map do |doc|
            doc['_index'] = arguments[:dest][:index]

            arguments[:transform]&.call(doc)

            doc['data'] = doc['_source']
            doc.delete('_score')
            doc.delete('_source')

            { index: doc }
          end

          arguments[:dest][:client].bulk body:
        end
      end
    end
  end
end
