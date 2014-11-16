module UsersHelper
  def _label
    content_tag 'div', class: 'label' do
      yield
    end
  end

  def _input
    content_tag 'div', class: 'input' do
      yield
    end
  end

  def _error
    content_tag 'div', class: 'error' do
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
    errors = form.object.errors[field]
    has_errors = errors.any?
    
    lbl = _label { form.label field, display_text }
    inp = _input { form.send(field_helper, field, opts) }
    err = _error { errors.join ", " } if has_errors
    clz = [:row]
    clz << :fieldWithErrors if has_errors
    content_tag 'div', class: clz.join(" ") do
      concat(lbl)
      concat(inp)
      concat(err) if has_errors
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
