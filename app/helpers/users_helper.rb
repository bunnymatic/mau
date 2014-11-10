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

  def user_signup_select_options(user)
    user.password = user.password_confirmation = nil 
    sel_opts = [{:key => :none,
                 :display => '&lt;select your account type&gt;',
                 :selected => '',
                 :id => 'select_account_default_option'
                 },
                 {:key => :Artist,
                 :display => "Mission Artist",
                 :selected => (@type == 'Artist') ? "selected=selected" : "" 
                 },
                 {:key => :MAUFan,
                 :display => "Mission Art Fan",
                 :selected => (@type == 'MAUFan') ? "selected=selected" : "" 
                 }]
    opts = sel_opts.map do |opt| 
      "<option value='#{opt[:key]}' " +
        "id='#{opt[:id]}' #{opt[:selected]}>" +
        "#{opt[:display]}</option>" 
    end.join('').html_safe
  end

end
