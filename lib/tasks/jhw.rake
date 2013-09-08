begin
  require 'jasmine-headless-webkit'
  Jasmine::Headless::Task.new('jasmine:headless') do |t|
    t.colors = true
    t.keep_on_error = true
    t.jasmine_config = 'spec/javascripts/support/jasmine.yml'
  end
rescue Exception => ex
  puts 'Jasmine headless webkit is unavailble - and you may not care unless you\'re trying to run Javascript tests'
end
