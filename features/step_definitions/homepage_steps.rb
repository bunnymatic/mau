Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .sampler__thumb')
end

Then(/^I see art newly added to the system$/) do
  expect(page).to have_selector('#new-art .square')
end

