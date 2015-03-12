Then(/^I see the admin roles page$/) do
  expect(page).to have_content "Roles & Members"
  expect(page).to have_selector ".editor.role_container .role_members li", count: Role.manager.users.count
  expect(page).to have_selector ".admin.role_container .role_members li", count: Role.manager.users.count
end

When(/^I click on the manage link for editors$/) do
  within(".editor.role_container") do
    click_on 'manage'
  end
end

When(/^I choose the last user in the user list$/) do
  users = all('select#user option')
  @new_editor = User.find(users.last['value'])
  select @new_editor.full_name, from: 'user'
end

Then(/^I expect to see the last user is now an editor$/) do
  expect(page).to have_selector '.members_edit .user', text: @new_editor.full_name
end

When(/^I remove a user from the editor list$/) do
  within all('.members_edit li').first do
    @previous_editor_name = find('.user').text.gsub(/\s+X$/, '')
    click_on 'X'
  end
end

Then(/^I expect to see that user is not an editor$/) do
  expect(page).to_not have_selector '.members_edit .user', text: @previous_editor_name
  expect(page).to have_selector('select option', text: @previous_editor_name)
end
