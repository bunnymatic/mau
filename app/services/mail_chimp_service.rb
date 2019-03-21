# frozen_string_literal: true

class MailChimpService
  API_KEY = Conf.mailchimp_api_key
  FAN_LIST_ID = Conf.mailchimp_fan_list_id
  ARTIST_LIST_ID = Conf.mailchimp_artist_list_id

  def initialize(user)
    @user = user
  end

  def subscribe_and_welcome
    raise 'Conf:mailchimp_api_key not set' if API_KEY.blank?
    return if @user.mailchimp_subscribed?

    subscribe
    @user.update(mailchimp_subscribed_at: Time.zone.now)
  end

  ATTRIBUTE_CONVERSIONS = {
    'firstname' => 'FNAME',
    'lastname' => 'LNAME',
  }.freeze

  def mailchimp_additional_data
    @user.attributes.slice(*ATTRIBUTE_CONVERSIONS.keys).each_with_object({}) do |(k, v), memo|
      memo[ATTRIBUTE_CONVERSIONS[k]] = v
    end
  end

  # http://www.mailchimp.com/api/rtfm/listsubscribe.func.php

  def client
    @client ||= Gibbon::Request.new(api_key: API_KEY)
  end

  def list
    @list ||= client.lists(list_id)
  end

  def list_id
    @list_id ||= @user.class == Artist ? ARTIST_LIST_ID : FAN_LIST_ID
  end

  def subscribe
    list.members.create(
      body: {
        email_address: @user.email,
        status: 'subscribed',
        merge_fields: mailchimp_additional_data,
        email_type: 'html',
      },
    )
  end
end
