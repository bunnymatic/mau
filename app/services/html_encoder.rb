# frozen_string_literal: true

class HtmlEncoder
  def self.coder
    @coder ||= HTMLEntities.new
  end

  def self.encode(string)
    coder.encode(string, :named, :hexadecimal)
  end
end
