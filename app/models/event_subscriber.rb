require 'net/http'
require 'cgi'
require 'uri'

class EventSubscriber < ActiveRecord::Base

  validates_presence_of :event_type
  validates_inclusion_of :event_type, :in => [ OpenStudiosSignupEvent, GenericEvent ].map(&:to_s)
  validates_format_of :url, :with => URI::regexp(%w(http https))

  def publish(ev)
    if ev
      begin
        resp = http_get(url,ev.attributes)
        if resp.code != 200
          RAILS_DEFAULT_LOGGER.warn "Failed to publish #{ev.inspect} to subscriber : Status => #{resp.code}"
        else 
          RAILS_DEFAULT_LOGGER.info "Sent #{ev.inspect} to subscriber #{self.inspect} with status #{resp.code}"
        end
      rescue Exception => ex
        RAILS_DEFAULT_LOGGER.warn "Failed to publish #{ev.inspect} to subscriber #{self.inspect} => #{ex}"
      end
    end
  end

  private
  def http_get(url,params)
    qstring = params.select{|k,v| v.present?}.map do |k,v| 
      val = v
      if (val.is_a? Hash) || (val.is_a? Array)
        val = val.to_json
      end
      "#{k}=#{CGI::escape(val.to_s)}" 
    end.join('&') unless params.nil? || params.empty?
    parameterized_url = [url, qstring].compact.join("?")
    uri =  URI.parse(parameterized_url)
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path)
    http.request(req)
  end

end
