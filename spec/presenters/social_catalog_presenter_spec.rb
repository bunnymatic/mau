require 'spec_helper'

describe SocialCatalogPresenter do

  fixtures :users, :artist_infos, :roles, :studios, :art_pieces,:media, :art_pieces_tags

  let(:social_keys) { SocialCatalogPresenter::SOCIAL_KEYS }
  let(:parsed) { CSV.parse(subject.csv, :headers => true) }
  its("artists.to_a") do
    should eql (Artist.active.open_studios_participants.select{|a|
                  social_keys.map{|s| a.send(s).present?}.any?
                }).sort(&Artist::SORT_BY_LASTNAME)
  end

  its(:csv_headers) { should eql subject.send(:csv_keys).map{|k| k.to_s.humanize.capitalize} }
  its(:csv_filename) { should eql "mau_social_artists_#{Conf.oslive.to_s}.csv" }
  it 'includes the right data in the csv' do
    expected_artists = Artist.active.open_studios_participants.select do |a|
      social_keys.map{|s| a.send(s).present?}.any?
    end
    expect(parsed).to have(expected_artists.count).rows
    artist = expected_artists.first
    row = parsed.detect{|row| row['Full name'] == artist.full_name}
    expect(row).to be_present
    expect(row['Email']).to eql artist.email
    expect(row["Facebook"]).to eql artist.facebook.to_s
    expect(row["Twitter"]).to eql artist.twitter.to_s
  end

end
