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
require 'logger'

# Mock the Backup modules and classes so we're not depending on the gem in the unit test
#
module Backup
  class Error < StandardError; end

  class Logger < ::Logger
    def self.logger
      new($stderr)
    end
  end

  module Config
    module DSL
    end
  end

  module Database
    class Base
      def dump_path = 'dump_path'
      def dump_filename = 'dump_filename'

      def log!(*_args)
        puts 'LOGGING...' if ENV['DEBUG']
      end

      def perform!
        puts 'PERFORMING...' if ENV['DEBUG']
      end
    end
  end
end

require 'opensearch/extensions/backup'
require 'debug'
module OpenSearch
  module Extensions
    class BackupTest < OpenSearch::Test::UnitTestCase
      context 'The Backup gem extension' do
        setup do
          @model = stub trigger: true
          @subject = ::Backup::Database::OpenSearch.new(@model)
        end

        should 'have a client' do
          assert_instance_of OpenSearch::Client, @subject.client
        end

        should 'have a path' do
          assert_instance_of Pathname, @subject.path
        end

        should 'have defaults' do
          assert_equal 'http://localhost:9200', @subject.url
          assert_equal '_all', @subject.indices
        end

        should 'be configurable' do
          @subject = ::Backup::Database::OpenSearch.new(@model) do |db|
            db.url = 'https://example.com'
            db.indices = 'foo,bar'
          end

          assert_equal 'https://example.com', @subject.url
          assert_equal 'foo,bar', @subject.indices
        end

        should 'perform the backup' do
          @subject.expects(:__perform_single)
          @subject.perform!
        end

        should 'raise an expection for an unsupported type of backup' do
          @subject = ::Backup::Database::OpenSearch.new(@model) { |db| db.mode = 'foobar' }
          assert_raise ::Backup::Database::OpenSearch::Error do
            @subject.perform!
          end
        end

        should 'scan and scroll the index' do
          @subject = ::Backup::Database::OpenSearch.new(@model) { |db| db.indices = 'test' }

          @subject.client
                  .expects(:search)
                  .with do |params|
            assert_equal 'test', params[:index]
            true # Thanks, Ruby 2.2
          end
            .returns({ '_scroll_id' => 'abc123' })

          @subject.client
                  .expects(:scroll)
                  .twice
                  .returns({
                             '_scroll_id' => 'def456',
                             'hits' => { 'hits' => [{ '_index' => 'test', '_type' => 'doc', '_id' => '1', '_source' => { 'title' => 'Test' } }] },
                           })
                  .then
                  .returns({
                             '_scroll_id' => 'ghi789',
                             'hits' => { 'hits' => [] },
                           })

          @subject.__perform_single
        end

        should 'sanitize filename' do
          assert_equal 'foo-bar-baz', @subject.__sanitize_filename("foo/bar\nbaz")
        end
      end
    end
  end
end
