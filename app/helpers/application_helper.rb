# Used by javascript automount to find all react components
REACT_COMPONENT_CLASS = 'react-component'.freeze

module ApplicationHelper
  def application_body_class(controller, body)
    [controller, body].flatten.compact.uniq.join ' '
  end

  def social_icon(icon)
    tag.i('', class: "ico ico-invert ico-#{icon}")
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

  def react_component(id:, component:, props: {}, wrapper_tag: 'div')
    camel_props = props.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    tag.send(wrapper_tag, { id: id, class: REACT_COMPONENT_CLASS, data: { component: component, react_props: camel_props } }) {}
  end

  if Gem::Version.new(Rails.version) < Gem::Version.new('6.1.0')
    def class_names(*args)
      args.each_with_object([]) do |arg, memo|
        if arg.is_a? Hash
          arg.select { |_k, v| v }.each_key { |k| memo << k }
        else
          memo << arg
        end
      end.join(' ')
    end
  end
end
