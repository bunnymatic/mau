Then(/^I see the admin dashboard$/) do
  expect(current_path).to eql admin_path
end
