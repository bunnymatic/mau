require 'net/http'
require 'cgi'
require 'uri'

class EventSubscriber < ActiveRecord::Base

  validates_presence_of :event_type
  validates_inclusion_of :event_type, :in => [ OpenStudiosSignupEvent, GenericEvent ].map(&:to_s)
  validates_format_of :url, :with => URI::regexp(%w(http https))

  def publish(ev)
    if ev
      http_get(url,ev.attributes)
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
    return Net::HTTP.get( URI.parse(parameterized_url))
  end

end
