Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .allthumbs .artp-thumb-container.with-foot')
end

Then(/^I see art newly added to the system$/) do
  expect(page).to have_selector('.new_art_thumbs a')
end
