# Rails.root/config.ru
require ::File.expand_path('config/environment', __dir__)

run Mau::Application
