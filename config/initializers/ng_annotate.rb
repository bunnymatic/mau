# frozen_string_literal: true

Rails.application.configure do
  config.ng_annotate.paths = [
    Rails.root.join('app', 'assets', 'components').to_s,
    Rails.root.join('app', 'assets', 'javascripts').to_s,
  ]
  config.ng_annotate.ignore_paths = [
    Rails.root.join('app', 'assets', 'javascripts', 'mau').to_s,
    Rails.root.join('app', 'assets', 'javascripts', 'admin').to_s,
  ]
end
