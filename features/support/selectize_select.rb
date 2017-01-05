# Support for multiple selects (just call select_from_chosen as many times as required):
module SelectizeSelect
  def select_from_selectize(item_text, options)
    field = find_field(options[:from], visible: false)
    debugger
    control = 1; # $('#art_piece_medium_id')[0].selectize.close()
    option_value = page.evaluate_script("$(\"##{field[:id]} option:contains('#{item_text}')\").val()")
    page.execute_script("value = ['#{option_value}']\; if ($('##{field[:id]}').val()) {$.merge(value, $('##{field[:id]}').val())}")
    option_value = page.evaluate_script("value")
    page.execute_script("$('##{field[:id]}').val(#{option_value})")
    page.execute_script("$('##{field[:id]}').close()")
  end
end

World SelectizeSelect
