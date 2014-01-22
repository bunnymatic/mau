module UsersHelper
  def _label
    content_tag 'div', :class => 'label' do
      yield
    end
  end

  def _input
    content_tag 'div', :class => 'input' do
      yield
    end
  end

  def add_http(lnk)
    if lnk && !lnk.empty? && lnk.index('http') != 0
      lnk = 'http://' + lnk
    end
    lnk
  end

  def signup_form_row(form, field, field_helper, opts = {})
    display_text = opts[:display] || field.to_s.humanize.titleize

    lbl = _label { form.label field, display_text }
    inp = _input { form.send(field_helper, field) }

    content_tag 'div', :class => 'row' do
      concat(lbl)
      concat(inp)
    end
  end
end
