# frozen_string_literal: true

module ApplicationHelper
  def application_body_class(controller, body)
    [controller, body].flatten.compact.uniq.join ' '
  end

  def social_icon(icon)
    content_tag('i', '', class: "ico ico-invert ico-#{icon}")
  end

  def link_to_icon(url, icon, link_opts = {})
    link_to(url, link_opts) do
      fa_icon(icon)
    end
  end

  def mau_spinner
    '<div class="mau-spinner">' \
    '<div></div><div></div><div></div><div></div>' \
    '<div></div><div></div><div></div><div></div>' \
    '<div></div><div></div><div></div><div></div>' \
    '</div>'.html_safe
  end

  def background_image_style(img)
    "background-image: url(\"#{img}\");"
  end
end
