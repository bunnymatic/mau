Given(/^an account has been created/) do
  @artist = Artist.where(:login => 'bmatic')
  if !@artist
    FactoryGirl.create(:artist, :activated, :with_art, :login => 'bmatic', :password => 'bmatic')
  end
end

Given /there are artists with art in the system/ do
  FactoryGirl.create_list(:art_piece, 10)
end
