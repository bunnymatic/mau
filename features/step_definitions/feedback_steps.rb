# frozen_string_literal: true
When(/^I fill in the feedback form$/) do
  within '#feedback' do
    fill_in 'feedback_comment', with: 'this is my feedback'
    click_on 'Send'
  end
end

Then(/^I see that my feedback was submitted$/) do
  expect(page).to have_css '.popup-help-text.feedback_msg', text: /thanks/i
end

Then(/^the system knows that my feedback was submitted$/) do
  expect(Feedback.last.comment).to eql 'this is my feedback'
end
