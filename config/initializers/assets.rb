  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
Rails.application.config.assets.precompile += %w( admin.js admin.css mau.css gmaps/google.js catalog.css event_calendar.js event_calendar.css mau-mobile.css)
Rails.application.config.assets.precompile += %w(.svg .eot .woff .ttf)
Rails.application.config.assets.paths << Rails.root.join('app/assets/components')
