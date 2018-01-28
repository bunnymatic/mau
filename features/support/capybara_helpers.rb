# frozen_string_literal: true

module CapybaraHelpers
  ##
  #
  # Finds the first button or link by id, text or value and clicks it. Also looks at image
  # alt text inside the link.
  #
  # @param [String] locator      Text, id or value of link or button
  #
  def click_on_first(locator, options = {})
    links = nil
    wait_until do
      links = all(:link_or_button, locator, options)
      links.present?
    end
    if running_js?
      links.first.trigger('click')
    else
      links.first.click
    end
  end

  def javascript_driver?
    Capybara.current_driver == Capybara.javascript_driver
  end

  def wait_until(time = Capybara.default_max_wait_time)
    Timeout.timeout(time) do
      loop do
        break if yield
        sleep 0.01
      end
    end
  end

  def table_row_matching(content)
    content_matcher = content.is_a?(String) ? /#{content}/ : content
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
end

World CapybaraHelpers
