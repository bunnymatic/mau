if ['test','development'].include? Rails.env
  require 'jasmine-headless-webkit'
  Jasmine::Headless::Task.new('jasmine:headless') do |t|
    t.colors = true
    t.keep_on_error = true
    t.jasmine_config = 'spec/javascripts/support/jasmine.yml'
  end
end
