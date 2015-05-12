Then(/^I see some of the art that's in the system$/) do
  expect(page).to have_selector('#sampler .sampler__thumb')
end

Then(/^I see art newly added to the system$/) do
  expect(page).to have_selector('#new-art .square')
end

When(/^I fill in the inquiry form$/) do
  within '.popup-text' do
    fill_in 'Email', with: 'joe@example.com'
    fill_in 'Confirm Email', with: "joe@example.com"
    fill_in 'Your Question', with: "what is the meaning of life?"
  end
end

Then(/^I see that my inquiry was submitted$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^the system knows that my inquiry was submitted$/) do
  pending # Write code here that turns the phrase above into concrete actions
end
