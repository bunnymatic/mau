module HTMLEncoder
  def html_encode(string, type = nil)
    method = type.present? ? [type] : %i[named hexadecimal]
    args = [string, method].flatten.compact
    HTMLEntities.new.encode(*args)
  end
end

RSpec.configure do |config|
  config.include HTMLEncoder
end
