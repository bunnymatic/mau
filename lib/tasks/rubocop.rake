begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError => ex
  puts "Rubocop is unavailable"
end
