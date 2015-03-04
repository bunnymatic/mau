require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {debug: false, js_errors: true})
end
Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :poltergeist
#Capybara.javascript_driver = :chrome
