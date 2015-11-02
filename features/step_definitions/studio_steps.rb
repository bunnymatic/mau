Then(/^I see the admin studios list$/) do
  s = Studio.last
  expect(page).to have_content s.name
  expect(page).to have_link('Show', href: studio_path(s))
end

Then(/^I see update studio links for things I can manage/) do
  s = @manager.studio
  expect(Studio.all).to have_at_least(2).studios
  expect(page).to have_link('Edit', href: edit_admin_studio_path(s))
  expect(page).to have_link('Show', count: Studio.all.count)
end

When(/^I edit the first studio$/) do
  within '.admin.studios #studios_index' do
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
  studio = Studio.by_position.first
  expect(current_path).to eql studio_path(studio.to_param)
  expect(page).to have_content studio.name
end

Then /^I see the studio page for me$/ do
  s = (@manager || @artist || @user).studio
  expect(current_path).to eql studio_path(s)
  expect(page).to have_content s.name
end

Then(/^I see the studio page for "(.*)"/) do |studio_slug|
  s = Studio.find(studio_slug)
  expect(current_path).to eql studio_path(s)
  expect(page).to have_content s.name
end

Then /^I see that some studios are participating in open studios$/ do
  expect(page).to have_selector '.studio-card .os-violator'
end

When /^I click on the first studio card$/ do
  all('.studio-card').first.click()
end

Then(/^I fill in the filter search box with "(.*?)"$/) do |studio|
  within '#js-studio-index-filter' do
    fill_in_field_with_value('filter', studio)
    find('[name=filter]').trigger 'change'
  end
end

Then(/^I only see the studio I was searching for$/) do
  expect(all('.studio-card').count).to eql 1
  expect(page).to have_content Studio.first.name
end

Then(/^I only see the "([^"]*)" studio card$/) do |title|
  wait_until do
    all('.studio-card').count == 1
  end
  expect(all('.studio-card').count).to eql 1
  within '.studio-card' do
    expect(page).to have_content title
  end
end
