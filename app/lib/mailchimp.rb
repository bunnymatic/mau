module MailChimp

  API_KEY = Conf.mailchimp_api_key
  FAN_LIST_ID = Conf.mailchimp_fan_list_id
  ARTIST_LIST_ID = Conf.mailchimp_artist_list_id

  def subscribe_and_welcome
    raise "Config:mailchimp_key not set" if API_KEY.blank?
    mailchimp_list_subscribe
    update_attribute(:mailchimp_subscribed_at, Time.zone.now)
  end

  private

  ATTRIBUTE_CONVERSIONS = {
    'firstname'              => 'FNAME',
    'lastname'             => 'LNAME',
    'activated_at'        => 'CREATED'
  }

  def mailchimp_additional_data
    attrs = attributes.keys.select{|k| ATTRIBUTE_CONVERSIONS.keys.include? k}
    conv = attrs.map{|k| [ATTRIBUTE_CONVERSIONS[k],send(k)] }
    Hash[conv]
  end

  # http://www.mailchimp.com/api/rtfm/listsubscribe.func.php

  def mailchimp_list_subscribe
    list_id = (self.class == Artist) ? ARTIST_LIST_ID : FAN_LIST_ID

    email_parts   = email.split('@')
    email_address = CGI::escape(email_parts[0]) + '@' + email_parts[1]

    gb       = Gibbon::API.new(API_KEY)
    response = gb.lists.subscribe(
      :id => list_id,
      :email => {:email => email_address},
      :merge_vars => mailchimp_additional_data,
      :email_type => 'text',
      :double_optin => false,
      :update_existing => true,
      :replace_interests => false,
      :send_welcome => true
    )

    raise "Failed to subscribe: " + response.to_s if !response
  end
end
