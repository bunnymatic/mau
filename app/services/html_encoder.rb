# frozen_string_literal: true

class HtmlEncoder
  def self.coder
    @coder ||= HTMLEntities.new
  end

  def self.encode(s)
    coder.encode(s, :named, :hexadecimal)
  end
end
