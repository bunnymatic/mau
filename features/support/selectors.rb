module Selectors
  Capybara.add_selector(:link_href) do
    xpath { |href| ".//a[@href='#{href}']" }
  end
end
