require 'simplecov'

# Writes the coverage stat to a file to be used by Cane.
class SimpleCov::Formatter::QualityFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    File.open("coverage/covered_percent", "w") do |f|
      f.puts result.source_files.covered_percent.to_f
    end
  end
end
SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/features/'
  add_group 'Controllers', 'app/controllers'
  add_group 'Forms', 'app/forms'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Presenters', 'app/presenters'
  add_group 'Views', 'app/views'
end

