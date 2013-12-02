Given(/^an account has been created/) do
  @artist = Artist.where(:login => 'bmatic').first
  if !@artist
    @artist = FactoryGirl.create(:artist, :activated, :with_art, :login => 'bmatic')
  end
  @artist.password = 'bmatic'
  @artist.password_confirmation = 'bmatic'
  @artist.save!
end

Given /there are artists with art in the system/ do
  FactoryGirl.create_list(:art_piece, 10)
end
