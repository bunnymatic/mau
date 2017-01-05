# Support for multiple selects (just call select_from_chosen as many times as required):
module SelectizeSelect

  # Select a single item from a selectized select input where multiple=false.
  def selectize_single_select(key, value)
    # It may be tempting to combine these into one execute_script, but don't; it will cause failures.
    page.execute_script %Q{ $('##{key}-selectized .selectize-input').click(); }
    page.execute_script %Q{ $('.#{key} .selectize-dropdown-content .option:contains("#{value}")').click(); }
  end

  # Select one or more items from a selectized select input where multiple=true.
  def selectize_multi_select(key, *values)
    values.flatten.each do |value|
      page.execute_script(%{
      $('##{key}-selectized').val('#{value}');
      $('##{key}')[0].selectize.createItem();
    })
    end
  end
end

World SelectizeSelect
