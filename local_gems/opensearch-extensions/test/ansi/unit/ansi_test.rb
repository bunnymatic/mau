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
require 'opensearch/extensions/ansi'

module OpenSearch
  module Extensions
    class AnsiTest < OpenSearch::Test::UnitTestCase
      context 'The ANSI extension' do
        setup do
          @client = OpenSearch::Client.new
          @client.stubs(:perform_request).returns \
            OpenSearch::Transport::Transport::Response.new(200,
                                                           {
                                                             'ok' => true,
                                                             'status' => 200,
                                                             'name' => 'Hit-Maker',
                                                             'version' => {
                                                               'number' => '0.90.7',
                                                               'build_hash' => 'abc123',
                                                               'build_timestamp' => '2013-11-13T12:06:54Z',
                                                               'build_snapshot' => false,
                                                               'lucene_version' => '4.5.1',
                                                             },
                                                             'tagline' => 'You Know, for Search',
                                                           })
        end

        should 'wrap the response' do
          response = @client.info

          assert_instance_of OpenSearch::Extensions::ANSI::ResponseBody, response
          assert_instance_of Hash, response.to_hash
        end

        should 'extend the response object with `to_ansi`' do
          response = @client.info

          assert_respond_to response, :to_ansi
          assert_instance_of String, response.to_ansi
        end

        should "call the 'awesome_inspect' method when available and no handler found" do
          @client.stubs(:perform_request).returns \
            OpenSearch::Transport::Transport::Response.new(200, { 'index-1' => { 'aliases' => {} } })
          response = @client.cat.aliases

          response.instance_eval do
            def awesome_inspect = '---PRETTY---'
          end
          assert_equal '---PRETTY---', response.to_ansi
        end

        should 'call `to_s` method when no pretty printer or handler found' do
          @client.stubs(:perform_request).returns \
            OpenSearch::Transport::Transport::Response.new(200, { 'index-1' => { 'aliases' => {} } })
          response = @client.cat.aliases

          assert_equal '{"index-1"=>{"aliases"=>{}}}', response.to_ansi
        end
      end
    end
  end
end
