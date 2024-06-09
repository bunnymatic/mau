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

ELASTICSEARCH_HOSTS = if (hosts = ENV['TEST_ES_SERVER'] || ENV.fetch('ELASTICSEARCH_HOSTS', nil))
                        hosts.split(',').map do |host|
                          %r{(http://)?(\S+)}.match(host)[2]
                        end
                      end.freeze

TEST_HOST, TEST_PORT = ELASTICSEARCH_HOSTS.first.split(':') if ELASTICSEARCH_HOSTS

JRUBY = defined?(JRUBY_VERSION)

if ENV['COVERAGE'] && ENV['CI'].nil?
  require 'simplecov'
  SimpleCov.start { add_filter '/test|test_' }
end

require 'minitest/autorun'
require 'shoulda-context'
require 'mocha/minitest'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'ansi/code'
require 'logger'

require 'opensearch/extensions'
require 'opensearch/extensions/test/startup_shutdown'
require 'opensearch/extensions/test/cluster'

module OpenSearch
  module Test
    module Assertions
      def assert_nothing_raised(*)
        yield
      end
    end

    class UnitTestCase < ::Minitest::Test
      include Assertions
      alias assert_not_nil refute_nil
      alias assert_raise assert_raises
    end

    class IntegrationTestCase < ::Minitest::Test
      include Assertions
      alias assert_not_nil refute_nil
      alias assert_raise assert_raises

      include OpenSearch::Extensions::Test
      extend  StartupShutdown

      startup do
        if ENV['SERVER'] && !OpenSearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
          OpenSearch::Extensions::Test::Cluster.start(number_of_nodes: 2)
        end
      end

      shutdown do
        if ENV['SERVER'] && OpenSearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
          OpenSearch::Extensions::Test::Cluster.stop(number_of_nodes: 2)
        end
      end
    end
  end
end
