Given(/^an account has been created/) do
  @artist = Artist.where(:login => 'bmatic').first
  if !@artist
    @artist = FactoryGirl.create(:artist, :activated, :with_art, :login => 'bmatic')
  end
  @artist.password = 'bmatic'
  @artist.password_confirmation = 'bmatic'
  @artist.save!
end

Given(/^an "(.*?)" account has been created/) do |role|
  @artist = Artist.where(:login => 'bmatic').first
  if !@artist
    @artist = FactoryGirl.create(:artist, :activated, :with_art, role.to_sym, :login => 'bmatic', )
  else
    @artist.roles = [role]
  end
  @artist.password = 'bmatic'
  @artist.password_confirmation = 'bmatic'
  @artist.save!
end

Given /there are artists with art in the system/ do
  @art_pieces = FactoryGirl.create_list(:art_piece, 10)
  @artists = (@artists || []) + @art_pieces.map(&:artist)
end

Given /there are users in the system/ do
  @users = FactoryGirl.create_list(:user, 4)
end

Given /there are tags on the art/ do
  @art_piece_tags = FactoryGirl.create_list(:art_piece_tag, 10)
  @art_pieces.each_with_index do |art, idx|
    art.tags = @art_piece_tags.sample([idx,10].min) + [@art_piece_tags.first]
    art.save!
  end
end

Given /there are events in the system/ do
  @events = FactoryGirl.create_list(:event, 5) + FactoryGirl.create_list(:event, 5, :with_reception)
end
