# frozen_string_literal: true

When(/^I fill in the inquiry form$/) do
  within '.ngdialog-content' do
    fill_in_field_with_value 'Email', 'joe@example.com'
    fill_in 'Confirm Email', with: 'joe@example.com'
    fill_in 'Your Question', with: 'what is the meaning of life?'
    click_on 'send'
  end
end

When(/^I fill in the help form$/) do
  within '.ngdialog-content' do
    fill_in_field_with_value 'Email', 'jo@example.com'
    fill_in 'Confirm Email', with: 'jo@example.com'
    fill_in 'What went wrong?', with: 'help me please'
    click_on 'send'
  end
end

Then(/^I see that my inquiry was submitted$/) do
  expect(page).to have_flash 'notice', /Thanks/
end

Then(/^the system knows that my inquiry was submitted$/) do
  expect(Feedback.last.email).to eql 'joe@example.com'
  expect(Feedback.last.comment).to match /is the meaning/
end

Then(/^the system knows that my help was submitted$/) do
  expect(Feedback.last.email).to eql 'jo@example.com'
  expect(Feedback.last.comment).to match /help me please/
end
