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
      module Helpers
        # Shortcut for {::ANSI::Table.new}
        #
        def table(data, options = {}, &)
          ::ANSI::Table.new(data, options, &)
        end

        # Terminal width, based on {::ANSI::Terminal.terminal_width}
        #
        def width
          ::ANSI::Terminal.terminal_width - 5
        end

        # Humanize a string
        #
        def humanize(string)
          string.to_s.tr('_', ' ').split.map(&:capitalize).join(' ')
        end

        # Return date formatted by interval
        #
        def date(date, interval = 'day')
          case interval
          when 'minute'
            "#{date.strftime('%a %m/%d %H:%M')} – #{(date + 60).strftime('%H:%M')}"
          when 'hour'
            "#{date.strftime('%a %m/%d %H:%M')} – #{(date + (60 * 60)).strftime('%H:%M')}"
          when 'day'
            date.strftime('%a %m/%d')
          when 'week'
            days_to_monday = date.wday.zero? ? 6 : date.wday - 1
            days_to_sunday = date.wday.zero? ? 0 : 7 - date.wday
            start = (date - (days_to_monday * 24 * 60 * 60)).strftime('%a %m/%d')
            stop  = (date + (days_to_sunday * 24 * 60 * 60)).strftime('%a %m/%d')
            "#{start} – #{stop}"
          when 'month'
            date.strftime('%B %Y')
          when 'year'
            date.strftime('%Y')
          else
            date.strftime('%Y-%m-%d %H:%M')
          end
        end

        # Output divider
        #
        def ___
          ('─' * Helpers.width).ansi(:faint)
        end
      end
    end
  end
end
