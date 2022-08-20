module FontAwesomeIconHelper
  def fa_icon(names = 'fa', options = {})
    font_awesome_icon(names, options)
  end

  def font_awesome_icon(names = 'flag', original_options = {})
    options = original_options.deep_dup
    classes = []
    classes.concat Private.icon_names(names)
    classes.concat Array(options.delete(:class))
    text = options.delete(:text)
    right_icon = options.delete(:right)
    icon = tag.i(nil, **options.merge(class: classes))
    Private.icon_join(icon, text, reverse: !!right_icon)
  end

  module Private
    extend ActionView::Helpers::OutputSafetyHelper

    SYNONYMS = {
      edit: 'pencil',
      remove: 'times',
      close: 'times',
    }.freeze

    def self.icon_join(icon, text, reverse: false)
      return icon if text.blank?

      elements = [icon, ERB::Util.html_escape(text)]
      elements.reverse! if reverse
      safe_join(elements, ' ')
    end

    def self.icon_names(names = [])
      array_value(names).map { |n| "fa fa-#{check_for_synonyms(n)}" }
    end

    def self.array_value(value = [])
      value.is_a?(Array) ? value : value.to_s.split(/\s+/)
    end

    def self.check_for_synonyms(name)
      SYNONYMS.fetch(name.to_sym, name)
    end
  end
end
