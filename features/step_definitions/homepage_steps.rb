Then(/^I should see some of the art that's in the system$/) do
  expect(page).to have_selector('.sampler img')
end

