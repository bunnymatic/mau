# frozen_string_literal: true

Mau::Application.configure do
  # config.angular_templates.module_name    = 'templates'
  # config.angular_templates.ignore_prefix  = %w(templates/)
  # config.angular_templates.inside_paths   = [Rails.root.join('app', 'assets')]
  # config.angular_templates.htmlcompressor = false
  config.angular_templates.markups = %w[erb slim]
end
