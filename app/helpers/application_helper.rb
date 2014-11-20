module ApplicationHelper
  def application_body_class
    [@current_controller, @body_classes].flatten.compact.uniq.join ' '
  end

  def social_icon(icon)
    content_tag('i', '', class: "ico-invert ico-#{icon}")
  end
end
