begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  # puts 'Rubocop is unavailable'
end
