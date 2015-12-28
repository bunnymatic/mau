require 'spec_helper'

describe AdminEmailList do

  before do
    FactoryGirl.create(:open_studios_event, :future)
    FactoryGirl.create_list(:artist, 2, :active)
    FactoryGirl.create_list(:artist, 2)
  end

  let(:current) { OpenStudiosEvent.current }
  let(:listname) { 'active' }
  subject(:email_list) { AdminEmailList.new(listname) }
  let(:emails) { email_list.emails }

  describe '#display_title' do
    subject { super().display_title }
    it { should eql "Activated [#{Artist.active.count}]" }
  end

  describe '#artists' do
    subject { super().artists }
    describe '#to_a' do
      subject { super().to_a }
      it { should eql Artist.active.to_a }
    end
  end

  describe '#csv_filename' do
    subject { super().csv_filename }
    it { should eql 'email_active.csv' }
  end

  it 'includes the normal lists' do
    %w(all active pending fans no_profile no_images).each do |k|
      expect(Hash[email_list.lists].keys).to include k
    end
  end

  context 'listname is fans' do
    let(:listname) { 'fans' }

    describe '#csv_filename' do
      subject { super().csv_filename }
      it { should eql 'email_fans.csv' }
    end

    it 'assigns a list of fans emails when we ask for the fans list' do
      expect(emails.length).to eql MAUFan.all.count
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      expect(email_list.display_title).to eq("Fans [#{email_list.artists.length}]")
    end

  end

  context 'listname is pending' do
    let(:listname) { 'pending' }

    describe '#csv_filename' do
      subject { super().csv_filename }
      it { should eql 'email_pending.csv' }
    end

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

    describe '#csv_filename' do
      subject { super().csv_filename }
      it { should eql 'email_' + listname.join("_") + ".csv" }
    end

    it 'returns emails that have been in both open studios' do
      expected = Artist.active.select{|a| a.os_participation[ostags.first]}.map(&:email) |
        Artist.active.select{|a| a.os_participation[ostags.last]}.map(&:email)
      expect(emails.map(&:email).sort).to eql expected.sort
    end
  end
end
