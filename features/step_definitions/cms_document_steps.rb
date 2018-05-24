# frozen_string_literal: true

Then(/^I see the cms content page$/) do
  expect(page.current_path).to eql admin_cms_documents_path
  expect(page).to have_css 'h1', text: 'CMS Content'
  expect(page).to have_css 'table.js-data-tables'
end

Then(/^I see no cms content in the list$/) do
  within 'table.js-data-tables' do
    expect(page).to have_content 'No data available in table'
  end
end
