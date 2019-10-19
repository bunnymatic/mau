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

  def nth_table_row(num)
    all('table tr')[num]
  end

  def last_table_row
    all('table tr').last
  end

  def first_table_row
    all('table tr').first
  end

  def table_header_cell_matching(content)
    content_matcher = content.is_a?(String) ? /#{content}/ : content
    match = all('table thead tr th').select do |cell|
      content_matcher =~ cell.text
    end
    match.first
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

  def path_from_title(titleized_path_name)
    clean_path_name = titleized_path_name.downcase.tr(' ', '_')
    path_helper_name = "#{clean_path_name}_path".to_sym
    send(path_helper_name)
  end

  def find_first_link_or_button(locator)
    find_links_or_buttons(locator).first
  end

  def find_last_link_or_button(locator)
    find_links_or_buttons(locator).last
  end

  # careful here with JS.  these don't "wait for" things to show up
  # so invisible buttons that may become visible because of animation
  # will cause issues - use click_on instead
  def all_links_or_buttons_with_title(title)
    all('a').select { |a| a['title'] == title } ||
      all('button').select { |b| b.value == title }
  end

  def find_links_or_buttons(locator)
    result = all("##{locator}") if /^-_[A-z][0-9]*$/.match?(locator)
    return result if result.present?

    result = all('a,button', text: locator)
    return result if result.present?

    all_links_or_buttons_with_title(locator)
  end
end

World CapybaraHelpers
