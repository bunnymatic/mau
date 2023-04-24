Then('I see that notification') do
  expect(page_body).to have_content @active_notification.message
end
