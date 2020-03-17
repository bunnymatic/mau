# frozen_string_literal: true

module SelectizeSelect
  def execute_script_string(js_string)
    # puts s
    page.execute_script(js_string)
  end

  def find_selectized_control_js(key)
    %{ $('##{key}.selectized').next('.selectize-control') }.strip
  end

  # Select a single item from a selectized select input where multiple=false given the id for base field
  def selectize_single_select(key, value)
    # It may be tempting to combine these into one execute_script, but don't; it will cause failures.
    execute_script_string %{ #{find_selectized_control_js(key)}.find('.selectize-input').click(); }
    execute_script_string %{ #{find_selectized_control_js(key)}.find(".selectize-dropdown-content .option:contains(\\\"#{value}\\\")").click(); }
  end

  # Select one or more items from a selectized select input where multiple=true.
  def selectize_multi_select(key, *values)
    values.flatten.each do |value|
      page.execute_script(%{
      #{find_selectized_control_js(key)}.find('input').val("#{value}");
      $('##{key}.selectized')[0].selectize.createItem();
    })
    end
  end
end

World SelectizeSelect
