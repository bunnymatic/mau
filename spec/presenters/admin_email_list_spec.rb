require 'rails_helper'

describe AdminEmailList do

  let(:current) { OpenStudiosEvent.current }
  let(:listname) { 'active' }
  subject(:email_list) { AdminEmailList.new(listname) }
  let(:emails) { email_list.emails }

  before do
    FactoryGirl.create(:open_studios_event, :future)
    artists = FactoryGirl.create_list(:artist, 2, :active)
    FactoryGirl.create_list(:artist, 2)
    artists.each do |artist|
      artist.artist_info.update_os_participation current.key, true
    end
  end

  its(:display_title) { is_expected.to eql "Activated [#{Artist.active.count}]" }
  its(:artists) { is_expected.to match_array Artist.active }
  its(:csv_filename) { is_expected.to eql 'email_active.csv' }

  it 'includes the normal lists' do
    %w(all active pending fans no_profile no_images).each do |k|
      expect(Hash[email_list.lists].keys).to include k
    end
  end

  context 'listname is fans' do
    let(:listname) { 'fans' }

    its(:csv_filename) { is_expected.to eql 'email_fans.csv' }

    it 'assigns a list of fans emails when we ask for the fans list' do
      expect(emails.length).to eql MauFan.all.count
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      expect(email_list.display_title).to eq("Fans [#{email_list.artists.length}]")
    end

  end

  context 'listname is pending' do
    let(:listname) { 'pending' }

    its(:csv_filename) { is_expected.to eql 'email_pending.csv' }

    it 'assigns a list of pending emails when we ask for the fans list' do
      expect(email_list.artists.to_a).to eql Artist.pending.to_a
    end

    it 'shows the title and list size and correct emails when we ask for pending' do
      expect(email_list.display_title).to eql "Pending [%s]" % Artist.pending.count
    end
  end

  describe "list name is an os event tag" do
    let!(:ostag) { current.key }
    let(:listname) { ostag }

    it "assigns a list of os artists" do
      expect(emails.length).to eql Artist.active.all.count{|a| a.os_participation[ostag]}
    end

    it "shows the title and list size and correct emails" do
      expected_participants = Artist.active.all.count{|a| a.os_participation[ostag]}
      expect(email_list.display_title).to eql "#{current.for_display} [#{expected_participants}]"
    end
  end

  context 'with multiple os tags' do
    let(:ostags) { OpenStudiosEvent.all.map(&:key) }
    let(:listname) { ostags }

    its(:csv_filename) { is_expected.to eql 'email_' + listname.join("_") + ".csv" }

    it 'returns emails that have been in both open studios' do
      expected = Artist.active.select{|a| a.os_participation[ostags.first]}.map(&:email) |
        Artist.active.select{|a| a.os_participation[ostags.last]}.map(&:email)
      expect(emails.map(&:email).sort).to eql expected.sort
    end
  end
end
