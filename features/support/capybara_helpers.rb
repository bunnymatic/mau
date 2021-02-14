module CapybaraHelpers
  ##
  #
  # Finds the first button or link by id, text or value and clicks it. Also looks at image
  # alt text inside the link.
  #
  # @param [String] locator      Text, id or value of link or button
  #
  def click_on_first(locator, options = {})
    click_on(locator, options.merge(match: :first))
  end

  def javascript_driver?
    Capybara.current_driver == Capybara.javascript_driver
  end

  def wait_until(time = Capybara.default_max_wait_time)
    Timeout.timeout(time) do
      loop do
        break if yield

        sleep 0.1
      end
    end
  end

  def table_row_matching(content)
    content_matcher = content.is_a?(String) ? /#{Regexp.quote(content)}/ : content
    match = all('table tbody tr').select do |row|
      content_matcher =~ row.text
    end
    match.first
  end

  def fill_in_selectize(field, with:)
    if with.is_a? Array
      with.each do |val|
        fill_in field, with: val
      end
    else
      fill_in field, with: with
    end
  end

  def scroll_to_position(xpos, ypos)
    script = <<-JS
      window.scrollTo(#{xpos},#{ypos});
    JS

    Capybara.current_session.driver.browser.execute_script(script)
  end

  def scroll_to_element(locator)
    return unless running_js?

    element = locator.is_a?(String) ? find(locator, visible: false) : locator

    script = <<-JS
      arguments[0].scrollIntoView(true);
    JS

    Capybara.current_session.driver.browser.execute_script(script, element.native)
  end
end

World CapybaraHelpers
