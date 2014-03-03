require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {debug: false, js_errors: true})
end

Capybara.javascript_driver = :poltergeist
