require 'spec_helper'

shared_examples_for MailChimp do
  before do
    MAIL_CHIMP_LIST_DATA = {"data"=>[{"modules"=>[], "name"=>"list2", "stats"=>{"avg_unsub_rate"=>0, "cleaned_count_since_send"=>1, "unsubscribe_count_since_send"=>0, "campaign_count"=>1, "member_count_since_send"=>0, "click_rate"=>21.052631578947, "avg_sub_rate"=>0, "member_count"=>133, "target_sub_rate"=>0, "unsubscribe_count"=>0, "cleaned_count"=>1, "merge_var_count"=>4, "group_count"=>0, "grouping_count"=>0, "open_rate"=>71.641791044776}, "default_language"=>"en", "default_from_name"=>"Mission Artists United", "subscribe_url_short"=>"http://eepurl.com/xNvrL", "email_type_option"=>false, "subscribe_url_long"=>"http://missionartistsunited.us2.list-manage.com/subscribe?u=a10070c7a519efbd75c4136a2&id=3e10b86ccc", "id"=>"list_id", "web_id"=>745369, "default_subject"=>"", "default_from_email"=>"trish@trishtunney.com", "list_rating"=>3.5, "visibility"=>"pub", "beamer_address"=>"us2-e7188aeb75-35be401f11@inbound.mailchimp.com", "use_awesomebar"=>true, "date_created"=>"2013-04-05 06:36:50"}], "total"=>1}

    Gibbon.stub(:new => double(:lists => MAIL_CHIMP_LIST_DATA))
  end
  describe '.mailchimp_list_id' do
    it 'raises if list name can\'t be found' do
      expect{ User.first.send(:mailchimp_list_id,'thing') }.to raise_error
    end
    it 'returns the list if the name is right' do
      User.first.send(:mailchimp_list_id,'list2').should eql 'list_id'
    end
  end

  describe '.mailchimp_list_subscribe' do
  end


end
