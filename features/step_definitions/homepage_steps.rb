# frozen_string_literal: true
Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .sampler__thumb')
end


