module MailChimp

  API_KEY = Conf.mailchimp_api_key
  if Rails.env == 'production'
    FANS_LIST = 'Mission Artists United Events Only'
    ARTISTS_LIST = 'Mission Artists United List'
  else
    FANS_LIST = 'test list fans'
    ARTISTS_LIST = 'test list artists'
  end

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

  def mailchimp_list_name
    (self.class == Artist) ? ARTISTS_LIST : FANS_LIST
  end

  def mailchimp_additional_data
    attrs = attributes.keys.select{|k| ATTRIBUTE_CONVERSIONS.keys.include? k}
    conv = attrs.map{|k| [ATTRIBUTE_CONVERSIONS[k],send(k)] }
    Hash[conv]
  end

  # http://www.mailchimp.com/api/rtfm/listsubscribe.func.php
  # public static listSubscribe(string apikey, string id, string email_address, array merge_vars, string email_type, bool double_optin, bool update_existing, bool replace_interests, bool send_welcome)

  # extract the list_id for the given list_name
  def mailchimp_list_id(list_name)
    gb       = Gibbon.new(API_KEY)
    response = gb.lists()
    lists    = response['data']
    list     = lists.find { |list| list['name'] == list_name }
    raise "List with name '#{list_name}' not found: " + response.to_s if list.nil?
    list["id"]
  end

  def mailchimp_list_subscribe
    list_id  = mailchimp_list_id( mailchimp_list_name )

    email_parts   = email.split('@')
    email_address = CGI::escape(email_parts[0]) + '@' + email_parts[1]

    gb       = Gibbon.new(API_KEY)
    response = gb.listSubscribe(
      :id                => list_id,
      :email_address     => email_address,
      :merge_vars        => mailchimp_additional_data,
      :email_type        => 'text',
      :double_optin      => false,
      :update_existing   => true,
      :replace_interests => false,
      :send_welcome      => true
    )

    raise "Failed to subscribe: " + response.to_s if !response
  end
end
