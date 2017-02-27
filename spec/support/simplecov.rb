# frozen_string_literal: true
require 'simplecov'

# Writes the coverage stat to a file to be used by Cane.
module SimpleCov
  module Formatter
    class QualityFormatter
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        File.open('coverage/covered_percent', 'w') do |f|
          f.puts result.source_files.covered_percent.to_f
        end
      end
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter

if ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/lib/restful_authentication/'
    add_filter '/config/'
    add_filter '/vendor/'
    add_filter '/spec/'
    add_filter '/features'
    add_group  'Models', 'app/models'
    add_group  'Controllers', 'app/controllers'
    add_group  'Helpers', 'app/helpers'
    add_group  'Mailers', 'app/mailers'
    add_group  'Paginators', 'app/paginators'
    add_group  'Exporters', 'app/exporters'
    add_group  'Services', 'app/services'
    add_group  'Presenters', 'app/presenters'
  end
end
