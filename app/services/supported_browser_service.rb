# frozen_string_literal: true

class SupportedBrowserService
  @browsers_json_file = Rails.root.join('browsers.json')

  def self.supported?(user_agent)
    return true if supported_browsers.blank?

    matcher = BrowserslistUseragent::Match.new(supported_browsers, user_agent)
    (matcher.browser? && matcher.version?(allow_higher: true))
  end

  def self.supported_browsers
    @supported_browsers ||=
      begin
        if File.exist?(@browsers_json_file) && !Rails.env.test?
          JSON.parse(File.open(@browsers_json_file).read)
        else
          []
        end
      end
  end

  # primarily for use in testing
  def self._reset
    @supported_browsers = nil
  end
end
