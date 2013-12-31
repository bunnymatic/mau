require 'spec_helper'

describe AdminEmailList do
  include OsHelper

  let(:listname) { 'active' }
  subject(:email_list) { AdminEmailList.new(listname) }
  let(:emails) { email_list.emails }

  its(:display_title) { should eql "Activated [#{Artist.active.count}]" }
  its("artists.to_a") { should eql Artist.active.to_a }
  
  it 'includes the normal lists' do
    %w(all active pending fans no_profile no_images).each do |k|
      Hash[email_list.lists].keys.should include k
    end
  end

  it 'includes all the os keys' do
    Conf.open_studios_event_keys.map(&:to_s).each do |k|
      Hash[email_list.lists].keys.should include k
    end
  end

  context 'listname is fans' do
    let(:listname) { 'fans' }
    it 'assigns a list of fans emails when we ask for the fans list' do
      emails.length.should eql MAUFan.all.count
    end

    it 'shows the title and list size and correct emails when we ask for fans' do
      email_list.display_title.should == "Fans [#{email_list.artists.length}]"
    end

  end

  context 'listname is pending' do
    let(:listname) { 'pending' }
    it 'assigns a list of pending emails when we ask for the fans list' do
      email_list.artists.to_a.should eql Artist.pending.to_a
    end

    it 'shows the title and list size and correct emails when we ask for pending' do
      email_list.display_title.should eql "Pending [%s]" % Artist.pending.count
    end
  end

  Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
    describe "list name is #{ostag}" do
      let(:listname) { ostag }
      it "assigns a list of os artists for #{ostag} when we ask for the #{ostag} list" do
        emails.length.should eql Artist.active.all.select{|a| a.os_participation[ostag]}.count
      end

      it "shows the title and list size and correct emails when we ask for #{ostag}" do
        expected_participants = Artist.active.all.select{|a| a.os_participation[ostag]}.count
        expected_tag = os_pretty(ostag)
        email_list.display_title.should eql "#{expected_tag} [#{expected_participants}]"
      end

    end
  end
  
end



      #   it 'the emails list is an intersection of all artists in those open studios groups' do
      #     emails = Artist.all.select{|a| a.os_participation['201004']}.map(&:email) |
      #       Artist.all.select{|a| a.os_participation['201010']}.map(&:email)
      #     emails.should eql assigns(:emails).map{|em| em[:email]}
      #   end
      #   it 'the emails list is an intersection of all artists in those open studios groups' do
      #     emails = Artist.all.select{|a| a.os_participation['201004']}.map(&:email) |
      #       Artist.all.select{|a| a.os_participation['201010']}.map(&:email)
      #     emails.should eql assigns(:emails).map{|em| em[:email]}
      #     emails.each do |em|
      #       assert_select '.email_results table tbody tr td', /#{em}/
      #     end
      #   end
