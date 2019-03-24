# frozen_string_literal: true

require Rails.root.join('config', 'environments', 'production')

Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: 'mau.rcode5.com',
  }
end
Rails.application.routes.default_url_options[:host] = 'mau.rcode5.com'
