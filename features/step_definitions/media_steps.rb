Then(/^I see the admin media list$/) do
  expect(current_path).to eql admin_media_path
end

When(/^I fill in "(.*?)" for "(.*?)"$/) do |arg1, arg2|
  fill_in arg2, :with => arg1
end

Then(/^I see the "(.*?)" as a medium$/) do |arg1|
  expect(page).to have_selector('.admin-table td.name', :text => arg1, :exact => true)
end

When(/^I click on the first medium$/) do
  medium_link = all('.art-piece__info .media medium a').first
  medium_path = medium_link['href']
  @medium = Medium.find( medium_path.gsub(/^\/media\//, '') )
  medium_link.click
end

Then(/^I see that medium detail page$/) do
  expect(current_path).to eql medium_path(@medium)
  expect(page).to have_css '.header', text: @medium.name
  expect(page).to have_css '.tagcloud li'
  expect(page).to have_css ".art-card .media a" do |tags|
    tags.each do |tag|
      expect(tag['href']).to eql media_path(@medium)
    end
  end
end
