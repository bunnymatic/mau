begin
  require 'guard/jasmine/task'
  namespace :spec do
    desc "Run all javascript specs"
    task :javascripts do
      begin
        require 'webmock'
        WebMock.disable!
        ::Guard::Jasmine::CLI.start([])

      rescue WebMock::NetConnectNotAllowedError => e
        # add this so we shut down the server properly
        puts e
        fail "WebMock got in the way"
      rescue SystemExit => e
        case e.status
          when 1
            fail "Some specs have failed."
          when 2
            fail "The spec couldn't be run: #{e.message}."
        end
      end
    end
  end
rescue LoadError
  namespace :spec do
    task :javascripts do
      puts "Guard/Jasmine may is not available in this environment: #{Rails.env}."
    end
  end
end

