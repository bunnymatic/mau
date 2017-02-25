# frozen_string_literal: true
module HTMLEncoder
  def html_encode(s, type = nil)
    method = type.present? ? [type] : [:named, :hexadecimal]
    args = [s, method].flatten.compact
    HTMLEntities.new.encode(*args)
  end
end

RSpec.configure do |config|
  config.include HTMLEncoder
end
