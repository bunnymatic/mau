Given(/^I'm on the subdomain (.*)$/) do |site_domain|
  site_domain = 'openstudios.lvh.me' if site_domain == 'openstudios'

  host! site_domain
  Capybara.app_host = "http://#{site_domain}"
end
