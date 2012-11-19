module UsersHelper
  def signup_form_row(form, field, field_helper, opts = {})
    display_text = opts[:display] || field.to_s.humanize.titleize
    
    label = content_tag 'div', :class => 'label' do
      form.label field, display_text
    end
    input = content_tag 'div', :class => 'input' do
      form.send(field_helper, field)
    end
    errors = content_tag 'div', :class => 'errors' do
      if (form.object.errors[field]) 
        content_tag 'div', :class => 'error-help' do
          concat([form.object.errors[field]].flatten.join(' and '))
        end
      end
    end

    content_tag 'div', :class => 'row' do
      concat(label)
      concat(input)
      concat(errors)
    end
  end
end
