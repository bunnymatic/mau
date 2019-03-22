# frozen_string_literal: true

require 'rails_helper'

describe AdminEmailList do
  let!(:open_studios_event) { FactoryBot.create(:open_studios_event, :future) }
  let(:current) { open_studios_event }
  let(:listname) { 'active' }
  subject(:email_list) { AdminEmailList.new(listname) }
  let(:emails) { email_list.emails }

  its(:display_title) { is_expected.to eql "Activated [#{Artist.active.count}]" }
  its(:artists) { is_expected.to match_array Artist.active }
  its(:csv_filename) { is_expected.to eql 'email_active.csv' }

  it 'includes the normal lists' do
    %w[all active pending fans no_profile no_images].each do |k|
      expect(Hash[email_list.lists].keys).to include k
    end
  end

  context 'listname is fans' do
    let(:listname) { 'fans' }

    let(:fans) do
      FactoryBot.build_stubbed_list(:mau_fan, 2, slug: SecureRandom.hex(5))
    end
    before do
      allow(MauFan).to receive(:all).and_return(fans)
    end

    its(:csv_filename) { is_expected.to eql 'email_fans.csv' }

    it 'assigns a list of fans emails when we ask for the fans list' do
      expect(emails.length).to eql 2
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      expect(email_list.display_title).to eq('Fans [2]')
    end
  end

  context 'listname is no_profile' do
    let(:listname) { 'no_profile' }
    let(:artists) do
      FactoryBot.build_stubbed_list(:artist, 1, slug: SecureRandom.hex(4))
    end
    let(:active_relation) do
      double('Artist::ActiveRecord_Relation',
             where: artists)
    end
    before do
      allow(Artist).to receive(:active).and_return(active_relation)
    end
    its(:csv_filename) { is_expected.to eql 'email_no_profile.csv' }

    it "assigns a list of emails of artists who don't have profile images" do
      expect(emails.length).to eql 1
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      expect(email_list.display_title).to eq('Active with no profile image [1]')
    end

    it 'gets artists without profile images' do
      emails
      expect(active_relation).to have_received(:where).with('profile_image is null')
    end
  end

  context 'listname is no_images' do
    let(:listname) { 'no_images' }
    let(:artists) do
      FactoryBot.build_stubbed_list(:artist, 1, slug: SecureRandom.hex(4))
    end
    before do
      allow(Artist).to receive(:active).and_return(artists)
    end

    its(:csv_filename) { is_expected.to eql 'email_no_images.csv' }

    it "assigns a list of emails of artists who don't have images" do
      expect(emails.length).to eql 1
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      expect(email_list.display_title).to eq('Active with no art [1]')
    end
  end

  context 'listname is pending' do
    let(:listname) { 'pending' }
    let(:pending_artists) do
      FactoryBot.build_stubbed_list(:artist, 1, :pending)
    end
    before do
      allow(Artist).to receive(:pending).and_return(
        double('Artist::ActiveRecord_Relation',
               all: pending_artists),
      )
    end

    its(:csv_filename) { is_expected.to eql 'email_pending.csv' }

    it 'assigns a list of pending emails when we ask for the fans list' do
      expect(email_list.artists.to_a).to eql pending_artists
    end

    it 'shows the title and list size and correct emails when we ask for pending' do
      expect(email_list.display_title).to eql 'Pending [1]'
    end
  end

  describe 'list name is an os event tag' do
    let!(:ostag) { current.key }
    let(:listname) { ostag }
    let(:participants) do
      double('Artist::ActiveRecord_Relation',
             open_studios_participants: [
               FactoryBot.build_stubbed(:artist, :active, slug: 'xxx'),
               FactoryBot.build_stubbed(:artist, :active, slug: 'yyy'),
             ])
    end

    before do
      allow(Artist).to receive(:active).and_return(participants)
      emails
    end

    it 'assigns a list of os artists' do
      expect(emails.length).to eql(2)
    end

    it 'shows the title and list size and correct emails' do
      expect(email_list.display_title).to eql "#{current.for_display} [2]"
    end

    it 'calls with the right tag' do
      expect(participants).to have_received(:open_studios_participants).with(ostag)
    end
  end

  context 'with multiple os tags' do
    let(:ostags) { %w[20180101 20190101] }
    let(:listname) { ostags }

    let(:participants) do
      FactoryBot.build_stubbed_list(:artist, 1, :active, slug: SecureRandom.hex(10))
    end
    let(:active_relation) do
      double('Artist::ActiveRecord_Relation',
             open_studios_participants: participants)
    end

    before do
      allow(described_class).to receive(:available_open_studios_keys).and_return(ostags)
      allow(Artist).to receive(:active).and_return(active_relation)
      emails
    end

    its(:csv_filename) { is_expected.to eql 'email_' + listname.join('_') + '.csv' }

    it 'returns emails that have been in both open studios' do
      expect(emails.map(&:email)).to eql participants.map(&:email)
    end
    it 'returns emails that have been in both open studios' do
      expect(active_relation).to have_received(:open_studios_participants).with(ostags.last)
    end
  end
end
