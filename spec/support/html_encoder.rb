module HTMLEncoder
  def html_encode(s)
    HTMLEntities.new.encode(s, :named, :hexadecimal)
  end
end

RSpec.configure do |config|
  config.include HTMLEncoder
end
