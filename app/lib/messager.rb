# frozen_string_literal: true

# require 'faye'

FAYE_SERVER_URL = Conf.messaging_server || 'http://localhost:3030/maumessages'
SUBSCRIBER_TOKEN = Conf.messaging_token || 'whatevs_yo'

class ClientAuth
  def outgoing(_msg, _callback)
    # if msg['channel'] == '/meta/subscribe'
    #   msg['ext'] ||= {}
    #   msg['ext']['subscriberToken'] = SUBSCRIBER_TOKEN
    # end
    # callback.call msg
  end
end

class Messager
  def publish(_channel, _message)
    # EM.run {
    #   client = Faye::Client.new(FAYE_SERVER_URL)
    #   puts "Publish"
    #   client.publish channel, {:path => channel, :text => message, :env => Rails.env}
    # }
  end
end
