require 'net/http'
require 'uri'

class Scammer < ActiveRecord::Base
  validates_uniqueness_of   :faso_id

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk

  def self.importFromFASO
    # import data from FASO database
    uri = URI.parse("https://api.faso.com/1/scammers?key=2386ad2c89aa40dfa0ce90e868797a33&format=pipe")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.request_uri)
    resp = http.request(req)
    headers = []
    scammers = resp.body.map do |row| 
      row.chomp!
      (row.split '|').map{|entry| entry.gsub(/^"/, '').gsub(/"$/, '')}
    end.each do |items|
      if headers.empty?
        headers = items
      else
        v = Hash[headers.zip( items ) ]
        Scammer.new( :name => v['name_used'], :faso_id => v['id'], :email => v['email'])
      end
    end
    scammers.each do |s|
      s.save if s.valid?
    end
  end
end
