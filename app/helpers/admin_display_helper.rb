# frozen_string_literal: true

module AdminDisplayHelper
  def boolean_as_checkmark(value)
    value ? '&check;'.html_safe : ''
  end
end
