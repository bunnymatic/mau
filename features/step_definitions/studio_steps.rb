Then(/^I see the admin studios list$/) do
  s = Studio.last
  expect(page).to have_content s.name
  expect(page).to have_link('Show', href: studio_path(s))
  expect(page).to have_link('Edit', href: edit_admin_studio_path(s))
end

Then(/^I see update studio links for things i can manage/) do
  s = @manager.studio
  expect(Studio.all).to have_at_least(2).studios
  expect(page).to have_link('Edit', href: edit_admin_studio_path(s))
  expect(page).to have_link('Edit', count: 1)
  expect(page).to have_link('Show', count: Studio.all.count)

end

When(/^I edit the first studio$/) do
  within '.admin-table' do
    click_on_first 'Edit'
  end
end

When(/^I change the street address to "(.*?)"$/) do |street_address|
  fill_in "Street", with: street_address
  click_on 'Update Studio'
end

Then(/^I see the first studio has the street address "(.*?)"$/) do |street_address|
  expect(page).to have_content street_address
end

Then(/^I see the first studio page/) do
  expect(current_path).to eql studio_path(Studio.first.to_param)
end
