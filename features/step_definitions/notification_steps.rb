Then('I see that notification') do
  expect(page).to have_content @active_notification.message
end
