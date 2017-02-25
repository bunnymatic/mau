# frozen_string_literal: true
Then(/^I see the admin roles page$/) do
  expect(page).to have_content "Roles & Members"
  expect(page).to have_selector ".editor.role-container .role_members li", count: Role.editor.users.count
  expect(page).to have_selector ".admin.role-container .role_members li", count: Role.admin.users.count
end

When(/^I add a new role called "(.*)"$/) do |role|
  within '.header' do
    click_on 'add role'
  end
  fill_in "Role", with: role
  click_on 'Create Role'
end

When(/^I add a user to the "(.*)" role$/) do |role|
  step %(I click on the manage link for #{role}s)
  step %(I choose the last user in the user list)
  step %(I click "add user")
end

When(/^I remove the role "(.*)"$/) do |role|
  within ".#{role}.role-container" do
    click_on "destroy"
  end
end

Then(/^I see there is a role called "(.*?)"$/) do |role|
  expect(page).to have_selector ".#{role.downcase}.role-container .role_members li", count: Role.find_by_role(role).users.count
end

Then(/^I see there is a role called "(.*?)" with (\d+) users?$/) do |role, count|
  expect(page).to have_selector(".#{role.downcase}.role-container .role_members li", count: count)
end

Then(/^I see there is not a role called "(.*?)"$/) do |role|
  expect(page).to_not have_selector(".#{role.downcase}.role-container")
  expect(Role.where(role: role)).to be_empty
end

When(/^I click on the manage link for (.*)s$/) do |role|
  within(".#{role}.role-container") do
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
