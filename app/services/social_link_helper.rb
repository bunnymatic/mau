class SocialLinkHelper
  attr_reader :link

  def initialize(link)
    @link = link
  end

  def handle
    return unless instagram?

    link[%r{instagram\.com/([^/?]*)}, 1]
  end

  def instagram?
    link? && link.include?('instagram.com/')
  end

  def link?
    return false if link.blank?

    link =~ /^https?:/
  end
end
