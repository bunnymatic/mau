# frozen_string_literal: true
class String
  def handleize
    to_s.gsub(/\s+/, '_').camelize
  end
end
