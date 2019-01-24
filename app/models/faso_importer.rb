# frozen_string_literal: true

class FasoImporter
  include Enumerable

  def initialize
    @headers = nil
  end

  def scammers
    @scammers ||= fetch
  end

  def uri
    @uri ||= URI.parse('https://api.faso.com/1/scammers?key=2386ad2c89aa40dfa0ce90e868797a33&format=pipe')
  end

  def fetch
    # import data from FASO database
    faso_data.map do |row|
      entry = parse_row(row)
      next unless entry

      name = entry['name_used'].encode('utf-8', invalid: :replace, undef: :replace)
      Scammer.new(name: name, faso_id: entry['id'], email: entry['email'])
    end.compact.uniq
  end

  def each(&block)
    scammers.each(&block)
  end

  private

  def faso_data
    @faso_data ||=
      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        http.request(req)
      end.body.split("\n").map(&:chomp)
  end

  def parse_row(row)
    if !@headers
      @headers = pipe_split(row)
      nil
    else
      Hash[@headers.zip(pipe_split(row))]
    end
  end

  def pipe_split(row)
    (row.split '|').map { |entry| entry.gsub(/^"/, '').gsub(/"$/, '') }
  end
end
