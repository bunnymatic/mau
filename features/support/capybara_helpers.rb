module CapybaraHelpers
  ##
  #
  # Finds the first button or link by id, text or value and clicks it. Also looks at image
  # alt text inside the link.
  #
  # @param [String] locator      Text, id or value of link or button
  #
  def click_on_first(locator, options={})
    all(:link_or_button, locator, options).first.click
  end

  def javascript_driver?
    Capybara.current_driver == Capybara.javascript_driver
  end

  def wait_until(time = Capybara.default_wait_time, &block)
    Timeout.timeout(time) do
      loop do
        break if block.call
        sleep 0.01
      end
    end
  end
  
end

World CapybaraHelpers
