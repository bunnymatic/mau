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

require 'ruby-prof'
require 'benchmark'
require 'ansi'

module OpenSearch
  module Extensions
    module Test
      # Allows to define and execute profiling tests within [Shoulda](https://github.com/thoughtbot/shoulda) contexts.
      #
      # Measures operations and reports statistics, including code profile.
      #
      # Uses the "benchmark" standard library and the "ruby-prof" gem.
      #
      #     File: profiling_test.rb
      #
      #     require 'test/unit'
      #     require 'shoulda/context'
      #     require 'opensearch/extensions/test/profiling'
      #
      #     class ProfilingTest < Test::Unit::TestCase
      #       extend OpenSearch::Extensions::Test::Profiling
      #
      #       context "Mathematics" do
      #         measure "divide numbers", count: 10_000 do
      #           assert_nothing_raised { 1/2 }
      #         end
      #       end
      #
      #     end
      #
      #     $ QUIET=y ruby profiling_test.rb
      #
      #     ...
      #     ProfilingTest
      #
      #     -------------------------------------------------------------------------------
      #     Context: Mathematics should divide numbers (10000x)
      #     mean: 0.03ms | avg: 0.03ms | max: 0.14ms
      #     -------------------------------------------------------------------------------
      #          PASS (0:00:00.490) test: Mathematics should divide numbers (10000x).
      #     ...
      #
      module Profiling
        # Profiles the passed block of code.
        #
        #     measure "divide numbers", count: 10_000 do
        #      assert_nothing_raised { 1/2 }
        #     end
        #
        # @todo Try to make progress bar not to interfere with tests
        #
        def measure(name, options = {}, &block)
          ___          = '-' * ANSI::Terminal.terminal_width
          test_name    = name
          suite_name   = self.name.split('::').last
          context_name = context(nil) {}.first.parent.name
          count        = Integer(ENV['COUNT'] || options[:count] || 1_000)
          ticks        = []
          progress     = ANSI::Progressbar.new(suite_name, count) unless ENV['QUIET'] || options[:quiet]

          should "#{test_name} (#{count}x)" do
            RubyProf.start

            begin
              count.times do
                ticks << Benchmark.realtime { instance_eval(&block) }

                next unless progress

                RubyProf.pause
                progress.inc
                RubyProf.resume
              end
            ensure
              result = RubyProf.stop
              progress&.finish
            end

            total = result.threads.reduce(0) do |t, info|
              t += info.total_time
              t
            end
            mean  = ticks.sort[(ticks.size / 2).round - 1] * 1000
            avg   = (ticks.inject { |sum, el|
                       sum += el
                       sum
                     }.to_f / ticks.size) * 1000
            min   = ticks.min * 1000
            max   = ticks.max * 1000

            result.eliminate_methods!([/Integer#times|Benchmark.realtime|ANSI::Code#.*|ANSI::ProgressBar#.*/])
            printer = RubyProf::FlatPrinter.new(result)
            # printer = RubyProf::GraphPrinter.new(result)

            puts "\n",
                 ___,
                 "#{suite_name}: #{ANSI.bold(context_name)} should #{ANSI.bold(name)} (#{count}x)",
                 "total: #{sprintf('%.2f', total)}s | " \
                 "mean: #{sprintf('%.2f', mean)}ms | " \
                 "avg: #{sprintf('%.2f',  avg)}ms | " \
                 "min: #{sprintf('%.2f',  min)}ms | " \
                 "max: #{sprintf('%.2f',  max)}ms",
                 ___
            printer.print($stdout, {}) unless ENV['QUIET'] || options[:quiet]
          end
        end
      end
    end
  end
end
