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

