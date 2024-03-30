When(/^I fill in the inquiry form$/) do
  within '.ReactModal__Content' do
    fill_in_field_with_value 'Email', 'joe@example.com'
    fill_in 'Confirm Email', with: 'joe@example.com'
    fill_in 'Your Question', with: 'what is the meaning of life?'
    click_on 'Send'
  end
end

When(/^I fill in the feedback form$/) do
  within '.ReactModal__Content' do
    fill_in_field_with_value 'Email', 'joe@example.com'
    fill_in 'Confirm Email', with: 'joe@example.com'
    fill_in 'Your Comments', with: 'what is the meaning of life?'
    click_on 'Send'
  end
end

Then(/^I see that my inquiry was submitted$/) do
  expect(page).to have_flash 'notice', /Thanks/
end

Then(/^the system knows that my inquiry was submitted$/) do
  expect(Feedback.last.email).to eql 'joe@example.com'
  expect(Feedback.last.comment).to match /is the meaning/
end

When(/^I see the feedback form$/) do
  within '.ReactModal__Content' do |modal|
    expect(modal).to have_content /feedback/i
  end
end
