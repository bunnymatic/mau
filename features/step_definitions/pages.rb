When /^I visit the home page$/ do
  visit '/'
  expect(current_path).to eq '/'
end

When /^I visit the open studios page$/ do
  visit '/open_studios'
  expect(current_path).to eq '/open_studios'
end

When /^I visit the about page$/ do
  visit '/about'
  expect(current_path).to eq '/about'
end
