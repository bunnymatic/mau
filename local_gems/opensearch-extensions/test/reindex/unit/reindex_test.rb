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

require 'test_helper'
require 'opensearch/extensions/reindex'

module OpenSearch
  module Extensions
    class ReindexTest < OpenSearch::Test::UnitTestCase
      context 'The Reindex extension module' do
        DEFAULT_OPTIONS = { source: { index: 'foo', client: Object.new }, dest: { index: 'bar' } }.freeze

        should 'require options' do
          assert_raise ArgumentError do
            OpenSearch::Extensions::Reindex.new
          end
        end

        should 'allow to initialize the class' do
          assert_instance_of OpenSearch::Extensions::Reindex::Reindex,
                             OpenSearch::Extensions::Reindex.new(DEFAULT_OPTIONS)
        end

        should 'add the reindex to the API and client' do
          assert_includes OpenSearch::API::Actions.public_instance_methods.sort, :reindex
          assert_respond_to OpenSearch::Client.new, :reindex
        end

        should 'pass the client when used in API mode' do
          skip('verify open search fails for some reason')
          client = OpenSearch::Client.new

          OpenSearch::Extensions::Reindex::Reindex
            .expects(:new)
            .with({ source: { client: } })
            .returns(stub(perform: {}))

          client.reindex(body: {})
        end

        context 'when performing the operation' do
          setup do
            d = { '_id' => 'foo', '_type' => 'type', '_source' => { 'foo' => 'bar' } }
            @default_response = { 'hits' => { 'hits' => [d] } }
            @empty_response   = { 'hits' => { 'hits' => [] } }
            @bulk_request     = [
              {
                index: {
                  '_index' => 'bar',
                  '_type' => d['_type'],
                  '_id' => d['_id'],
                  'data' => d['_source'],
                },
              },
            ]
            @bulk_response = { 'errors' => false, 'items' => [{ 'index' => {} }, { 'index' => {} }] }
            @bulk_response_error = { 'errors' => true, 'items' => [{ 'index' => {} }, { 'index' => { 'error' => 'FOOBAR' } }] }
          end

          should 'scroll through the index and save batches in bulk' do
            client  = mock
            subject = OpenSearch::Extensions::Reindex.new source: { index: 'foo', client: },
                                                          dest: { index: 'bar' }

            client.expects(:search)
                  .returns({ '_scroll_id' => 'scroll_id_1' }.merge(Marshal.load(Marshal.dump(@default_response))))
            client.expects(:scroll)
                  .returns(Marshal.load(Marshal.dump(@default_response)))
                  .then
                  .returns(@empty_response).times(2)
            client.expects(:bulk)
                  .with(body: @bulk_request)
                  .returns(@bulk_response).times(2)

            result = subject.perform

            assert_equal 0, result[:errors]
          end

          should 'return the number of errors' do
            client  = mock
            subject = OpenSearch::Extensions::Reindex.new source: { index: 'foo', client: },
                                                          dest: { index: 'bar' }

            client.expects(:search).returns({ '_scroll_id' => 'scroll_id_1' }.merge(@default_response))
            client.expects(:scroll).returns(@empty_response)
            client.expects(:bulk).with(body: @bulk_request).returns(@bulk_response_error)

            result = subject.perform

            assert_equal 1, result[:errors]
          end

          should 'transform the documents with a lambda' do
            client  = mock
            subject = OpenSearch::Extensions::Reindex.new \
              source: { index: 'foo', client: },
              dest: { index: 'bar' },
              transform: lambda { |d|
                           d['_source']['foo'].upcase!
                           d
                         }

            client.expects(:search).returns({ '_scroll_id' => 'scroll_id_1' }.merge(@default_response))
            client.expects(:scroll).returns(@empty_response)
            client.expects(:bulk).with do |arguments|
              assert_equal 'BAR', arguments[:body][0][:index]['data']['foo']
              true
            end
                  .returns(@bulk_response)

            result = subject.perform

            assert_equal 0, result[:errors]
          end
        end
      end
    end
  end
end
