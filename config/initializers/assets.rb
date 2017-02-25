# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.5'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(zxcvbn.js admin.js admin.css mau.css markerclusterer.js gmaps/google.js catalog.css)
Rails.application.config.assets.precompile += %w(.svg .eot .woff .ttf)
Rails.application.config.assets.paths << Rails.root.join('app/assets/components')
