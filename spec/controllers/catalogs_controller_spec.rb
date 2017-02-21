require 'rails_helper'

describe CatalogsController do

  let(:jesse) { FactoryGirl.create(:artist, :active, :with_studio, :with_art, :with_links) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_studio, :with_art, :with_links) }

  let(:open_studios_event) { FactoryGirl.create(:open_studios_event) }

  before do
    Rails.cache.clear
    fix_leaky_fixtures
    artist
    jesse

    ActiveRecord::Base.connection.execute("update artist_infos " +
                                          "set open_studios_participation = '#{open_studios_event.key}'")
    allow_any_instance_of(Artist).to receive(:in_the_mission?).and_return(true)
  end

  describe "#show" do
    let(:catalog) { assigns(:catalog) }
    context 'format=html' do
      before do
        get :show
      end
      it{ expect(response).to be_success }
    end

    context 'format=csv' do
      render_views
      let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({:headers =>true}) }
      let(:parsed) { CSV.parse(response.body, parse_args) }

      before do
        get :show, :format => :csv
      end
      it { expect(response).to be_success }
      it { expect(response).to be_csv_type }
      it 'includes the right headers' do
        expected_headers =  ["First Name","Last Name","Full Name","Email", "Group Site Name",
                             "Studio Address","Studio Number","Cross Street 1","Cross Street 2","Media"]

        expect(parsed.headers).to eq(expected_headers)
      end

      it 'includes the right data' do
        expect(parsed.size).to eq(Artist.active.count)
        row = parsed.detect{|row| row['Full Name'] == artist.full_name}
        expect(row).to be_present
        expect(row['Email']).to eql artist.email
        expect(row["Media"]).to eql artist.art_pieces.map{|a| a.medium.try(:name)}.join(" ")
      end
    end

  end

  describe '#social' do
    context 'format=html' do
      before do
        get :social
      end
      it { expect(response).to_not be_success }
    end
    context 'format=csv' do
      let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({:headers =>true}) }
      let(:parsed) { CSV.parse(response.body, parse_args) }
      let(:social_keys) { SocialCatalogPresenter::SOCIAL_KEYS }
      before do
        get :social, :format => :csv
      end
      it { expect(response).to be_success }
      it { expect(response).to be_csv_type }

      it 'includes the right headers' do
        expected_headers = ["Studio", "Name", "Art URL", "Art Title", "Medium", "Tags", "MAU Link", "Email",
                            "Website", "Facebook", "Twitter", "Blog", "Pinterest",
                            "Myspace", "Flickr", "Instagram", "Artspan"]
        expect(parsed.headers).to eq(expected_headers)
      end

      it 'includes the right data' do
        expected_artists = Artist.active.open_studios_participants.select do |a|
          social_keys.map{|s| a.send(s).present?}.any?
        end
        expect(parsed.size).to eq(expected_artists.count)
        artist = expected_artists.first
        row = parsed.detect{|row| row['Name'] == artist.full_name}
        expect(row).to be_present
        expect(row['Email']).to eql artist.email

        expect(row["Facebook"]).to eql artist.facebook.to_s
        expect(row["Twitter"]).to eql artist.twitter.to_s
      end

    end

  end
end
