# frozen_string_literal: true

class Messager
  def publish(channel, message)
    Rails.logger.info "Skipping messager publish for cucumber tests: would have published #{channel} #{message}"
  end
end
