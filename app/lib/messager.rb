require 'faye'

FAYE_SERVER_URL = Conf.messaging_server || 'http://localhost:3030/maumessages';
SUBSCRIBER_TOKEN = Conf.messaging_token || 'whatevs_yo'

class ClientAuth
  def outgoing(msg,cb)
    if msg['channel'] == '/meta/subscribe'
      msg['ext'] ||= {}
      msg['ext']['subscriberToken'] = SUBSCRIBER_TOKEN
    end
    cb.call msg
  end
end

class Messager
  @@client = nil
  cattr_accessor :client
  def initialize
    unless @@client
      @@client = Faye::Client.new(FAYE_SERVER_URL)
      @@client.add_extension(ClientAuth.new)
      @@client.disable('websocket');
    end
  end

  def publish channel, message
    # Momentarily.later Proc.new {
    #   client.publish channel, {:path => channel, :text => message, :env => Rails.env}
    # }
  end

end


