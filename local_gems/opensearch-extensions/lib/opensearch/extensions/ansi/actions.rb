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
    module ANSI
      module Actions
        # Display shard allocation
        #
        def display_allocation_on_nodes(json, _options = {})
          return unless json['routing_nodes']

          output = [] << ''

          json['routing_nodes']['nodes'].each do |id, shards|
            output << ((json['nodes'][id]['name'] || id).to_s.ansi(:bold) + " [#{id}]".ansi(:faint))
            output << if shards.empty?
                        'No shards'.ansi(:cyan)
                      else
                        Helpers.table(shards.map do |shard|
                          [
                            shard['index'],
                            shard['shard'].to_s.ansi(shard['primary'] ? :bold : :clear),
                            shard['primary'] ? '◼'.ansi(:green) : '◻'.ansi(:yellow),
                          ]
                        end)
                      end
          end

          unless json['routing_nodes']['unassigned'].empty?
            output << ('Unassigned: '.ansi(:faint, :yellow) + "#{json['routing_nodes']['unassigned'].size} shards")
            output << Helpers.table(json['routing_nodes']['unassigned'].map do |shard|
              primary = shard['primary']

              [
                shard['index'],
                shard['shard'].to_s.ansi(primary ? :bold : :clear),
                primary ? '◼'.ansi(:red) : '◻'.ansi(:yellow),
              ]
            end,
                                    border: false)
          end

          output.join("\n")
        end

        # Display search results
        #
        def display_hits(json, _options = {})
          return unless json['hits'] && json['hits']['hits']

          output = [] << ''
          hits = json['hits']['hits']
          source = json['hits']['hits'].any? { |h| h['fields'] } ? 'fields' : '_source'
          properties = hits.filter_map { |h| h[source] ? h[source].keys : nil }.flatten.uniq
          max_property_length = properties.filter_map { |d| d.to_s.size }.max.to_i + 1

          hits.each_with_index do |hit, i|
            title = hit[source] && hit[source].select { |k, _v| %w[title name].include?(k) }.to_a.first
            size_length = hits.size.to_s.size + 2
            padding = size_length

            output << ("#{i + 1}. ".rjust(size_length).ansi(:faint) +
                      " <#{hit['_id']}> " +
                      (title ? title.last.to_s.ansi(:bold) : ''))
            output << Helpers.___

            %w[_score _index _type].each do |property|
              output << ((' ' * padding) + "#{property}: ".rjust(max_property_length + 1).ansi(:faint) + hit[property].to_s) if hit[property]
            end

            hit[source]&.each do |property, value|
              output << ((' ' * padding) + "#{property}: ".rjust(max_property_length + 1).ansi(:faint) + value.to_s)
            end

            # Highlight
            if hit['highlight']
              output << ''
              output << ("#{' ' * (padding + max_property_length + 1)}#{'Highlights'.ansi(:faint)}\n#{' ' * (padding + max_property_length + 1)}#{('─' * 10).ansi(:faint)}")

              hit['highlight'].each do |property, matches|
                line = ''
                line << ((' ' * padding) + "#{property}: ".rjust(max_property_length + 1).ansi(:faint))

                matches.each_with_index do |match, e|
                  line << ((' ' * padding) + ''.rjust(max_property_length + 1)) if e.positive?
                  line << '…'.ansi(:faint) unless hit[source][property] && hit[source][property].size <= match.size
                  line << match.strip.ansi(:faint).tr("\n", ' ')
                               .gsub(%r{<em>([^<]+)</em>}, '\1'.ansi(:clear, :bold))
                               .ansi(:faint)
                  line << '…'.ansi(:faint) unless hit[source][property] && hit[source][property].size <= match.size
                  line << ((' ' * padding) + ''.rjust(max_property_length + 1)) if e.positive?
                  line << "\n"
                end
                output << line
              end
            end

            output << ''
          end
          output << Helpers.___
          output << "#{hits.size.to_s.ansi(:bold)} of #{json['hits']['total']['value'].to_s.ansi(:bold)} results".ansi(:faint)

          output.join("\n")
        end

        # Display terms facets
        #
        def display_terms_facets(json, _options = {})
          return unless json['facets']

          output = [] << ''

          facets = json['facets'].select { |_name, values| values['_type'] == 'terms' }

          facets.each do |name, values|
            longest = values['terms'].map { |t| t['term'].size }.max
            max     = values['terms'].pluck('count').max
            padding = longest.to_i + max.to_s.size + 5
            ratio   = (Helpers.width - padding) / max.to_f

            output << "#{'Facet: '.ansi(:faint)}#{Helpers.humanize(name)}" << Helpers.___
            values['terms'].each_with_index do |value, _i|
              output << (value['term'].ljust(longest).ansi(:bold) +
                        ' [' + value['count'].to_s.rjust(max.to_s.size) + ']  ' \
                                                                          '' + ('█' * (value['count'] * ratio).ceil))
            end
          end

          output.join("\n")
        end

        # Display date histogram facets
        #
        def display_date_histogram_facets(json, options = {})
          return unless json['facets']

          output = [] << ''

          facets = json['facets'].select { |_name, values| values['_type'] == 'date_histogram' }
          facets.each do |name, values|
            max     = values['entries'].pluck('count').max
            padding = 27
            ratio   = (Helpers.width - padding) / max.to_f

            interval = options[:interval] || 'day'
            output << "#{'Facet: '.ansi(:faint)}#{Helpers.humanize(name)} #{interval ? "(by #{interval})".ansi(:faint) : ''}"
            output << Helpers.___
            values['entries'].each_with_index do |value, _i|
              output << (Helpers.date(Time.at(value['time'].to_i / 1000).utc, interval).rjust(21).ansi(:bold) +
                        ' [' + value['count'].to_s.rjust(max.to_s.size) + ']  ' \
                                                                          '' + ('█' * (value['count'] * ratio).ceil))
            end
          end

          output.join("\n")
        end

        # Display histogram facets
        #
        def display_histogram_facets(json, _options = {})
          return unless json['facets']

          output = [] << ''

          facets = json['facets'].select { |_name, values| values['_type'] == 'histogram' }
          facets.each_value do |values|
            max     = values['entries'].pluck('count').max
            padding = 27
            ratio   = (Helpers.width - padding) / max.to_f

            histogram = values['entries']
            histogram.each_with_index do |segment, i|
              key = i.zero? ? "<#{histogram[1]['key']}ms" : "#{segment['key']}ms"

              output << ("#{key.rjust(7)} #{'█' * (segment['count'] * ratio).ceil} [#{segment['count']}]")
            end
          end

          output.join("\n")
        end

        # Display statistical facets
        #
        def display_statistical_facets(json, _options = {})
          return unless json['facets']

          output = [] << ''

          facets = json['facets'].select { |_name, values| values['_type'] == 'statistical' }

          facets.each do |name, facet|
            output << "#{'Facet: '.ansi(:faint)}#{Helpers.humanize(name)}" << Helpers.___
            output << Helpers.table(facet.except('_type').to_a.map do |pair|
                                      [Helpers.humanize(pair[0]), pair[1]]
                                    end)
          end
          output.join("\n")
        end

        # Display the analyze output
        #
        def display_analyze_output(json, _options = {})
          return unless json['tokens']

          output = [] << ''

          max_length = json['tokens'].map { |d| d['token'].to_s.size }.max

          output <<  Helpers.table(json['tokens'].map do |t|
                                     [
                                       t['position'],
                                       t['token'].ljust(max_length + 5).ansi(:bold),
                                       "#{t['start_offset']}–#{t['end_offset']}",
                                       t['type'],
                                     ]
                                   end).to_s
          output.join("\n")
        end
      end
    end
  end
end
