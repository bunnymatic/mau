require 'config/environment'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins %r{https?://(.*\.)?1890bryant\.com}
    # regular expressions can be used here
    
    resource %r{(studios|artists)(\/\d+)?(\.json)?$},
      :methods => [:get], #, :put, :delete],
      :headers => ['Origin', 'Accept', 'ContentType']
      # headers to expose
      # :expose => ['MAU-Custom-Response-Header']
    
  end
end

use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new
