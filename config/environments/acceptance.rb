require Rails.root.join('config/environments/production')

Mau::Application.configure do

  config.action_mailer.default_url_options = {
    :host => 'mau.rcode5.com'
  }

end
Rails.application.routes.default_url_options[:host] = 'mau.rcode5.com'
