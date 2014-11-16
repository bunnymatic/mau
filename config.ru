# Rails.root/config.ru
require ::File.expand_path('../config/environment',  __FILE__)

require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '/assets/fontawesome*', headers: :any, methods: :get
  end
end

run Mau::Application

