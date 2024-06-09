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

module OpenSearch
  module Extensions
    module ANSI
      # Wrapper for the OpenSearch response body, which adds a {#to_ansi} method
      #
      class ResponseBody < DelegateClass(Hash)
        # Return a [colorized and formatted](http://en.wikipedia.org/wiki/ANSI_escape_code)
        # representation of the OpenSearch response for:
        #
        # * Search results (hits and highlights)
        # * Facets (terms, statistical, histogram, date_histogram)
        # * Analyze API output
        # * Shard allocation
        #
        # @example Display formatted search results
        #
        #     require 'opensearch/extensions/ansi'
        #     puts OpenSearch::Client.new.search.to_ansi
        #
        # @todo Add all facets and handlers for remaining response parts / types
        #
        def to_ansi(options = {})
          output = Actions.public_methods.select do |m|
            m.to_s =~ /^display_/
          end.map do |m|
            Actions.send(m, self, options)
          end

          if output.compact.empty?
            respond_to?(:awesome_inspect) ? awesome_inspect : inspect
          else
            output.compact.join("\n")
          end
        end
      end
    end
  end
end

module OpenSearch
  module Transport
    module Transport
      class Response
        # Wrap the response body in the {Extensions::ANSI::ResponseBody} class
        #
        def body_to_ansi
          Extensions::ANSI::ResponseBody.new @body
        end

        alias body_original body
        alias body body_to_ansi
      end
    end
  end
end
