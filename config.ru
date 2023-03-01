# Rails.root/config.ru
require ::File.expand_path('config/environment', __dir__)
use(ViteRuby::DevServerProxy, ssl_verify_none: true) if ViteRuby.run_proxy?

run Mau::Application
