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

  its(:display_title) { should eql "Activated [#{Artist.active.count}]" }
  its("artists.to_a") { should eql Artist.active.to_a }
  its(:csv_filename) { should eql 'email_active.csv' }

  it 'includes the normal lists' do
    %w(all active pending fans no_profile no_images).each do |k|
      Hash[email_list.lists].keys.should include k
    end
  end

  context 'listname is fans' do
    let(:listname) { 'fans' }

    its(:csv_filename) { should eql 'email_fans.csv' }

    it 'assigns a list of fans emails when we ask for the fans list' do
      emails.length.should eql MAUFan.all.count
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      email_list.display_title.should == "Fans [#{email_list.artists.length}]"
    end

  end

  context 'listname is pending' do
    let(:listname) { 'pending' }

    its(:csv_filename) { should eql 'email_pending.csv' }

    it 'assigns a list of pending emails when we ask for the fans list' do
      email_list.artists.to_a.should eql Artist.pending.to_a
    end

    it 'shows the title and list size and correct emails when we ask for pending' do
      email_list.display_title.should eql "Pending [%s]" % Artist.pending.count
    end
  end

  describe "list name is an os event tag" do
    let!(:ostag) { current.key }
    let(:listname) { ostag }
    
    it "assigns a list of os artists" do
      emails.length.should eql Artist.active.all.count{|a| a.os_participation[ostag]}
    end

    it "shows the title and list size and correct emails" do
      expected_participants = Artist.active.all.count{|a| a.os_participation[ostag]}
      email_list.display_title.should eql "#{current.for_display} [#{expected_participants}]"
    end
  end

  context 'with multiple os tags' do
    let(:ostags) { OpenStudiosEvent.all.map(&:key) }
    let(:listname) { ostags }

    its(:csv_filename) { should eql 'email_' + listname.join("_") + ".csv" }

    it 'returns emails that have been in both open studios' do
      expected = Artist.active.select{|a| a.os_participation[ostags.first]}.map(&:email) |
        Artist.active.select{|a| a.os_participation[ostags.last]}.map(&:email)
      expect(emails.map(&:email).sort).to eql expected.sort
    end
  end
end
