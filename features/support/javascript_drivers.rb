require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {debug: false, js_errors: true})
end
Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
end

#Capybara.javascript_driver = :poltergeist
Capybara.javascript_driver = :webkit

# webkit only
Before('@javascript') do |scenario, block|
  page.driver.block_unknown_urls
end

module JavascriptDriverChecker
  def running_js?
    [:selenium, :webkit, :chrome, :poltergeist].include?(Capybara.current_driver)
  end
end

World JavascriptDriverChecker
