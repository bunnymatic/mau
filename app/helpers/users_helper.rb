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
    display_text = opts.delete(:display) || field.to_s.humanize.titleize

    lbl = _label { form.label field, display_text }
    inp = _input { form.send(field_helper, field, opts) }

    content_tag 'div', :class => 'row' do
      concat(lbl)
      concat(inp)
    end
  end

  def user_signup_select_options(user, type)
    user.password = user.password_confirmation = nil 
    entries = [['<select your account type>', ''],
               ['Mission Art Fan', :MAUFan],
               ['Mission Artist', :Artist]]
    options = {
      disabled: [entries.first.first],
      selected: [type.present? ? type : entries.first.first]
    }
    options_for_select( entries, options )
  end

end
