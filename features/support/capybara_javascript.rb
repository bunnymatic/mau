module Capybara
  module Node
    module Actions
      def locator_css(item_types, locator)
        tag_names = [item_types].flatten
        key = locator.downcase
        tag_names.map{|f| ["##{key}", "[title=#{locator}]", "[name=#{locator}]"].map{|k| [f,k].join}}.flatten
      end

      def fill_in(locator, options={})
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        with = options.delete(:with)
        css = locator_css(%w(input textarea), locator)
        find(:css, css, options).set(with)
      end

      def click_link_or_button(locator, options={})
        css = locator_css(%w(input button a), locator)
        find(:css, css, options).click
      end

      alias_method :click_on, :click_link_or_button

    end
  end
end
