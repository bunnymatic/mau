class DenylistDomain < ApplicationRecord
  DOMAIN_REGEX = /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,7}\z/
  DOMAIN_MESSAGE = 'This domain does not appear to be valid.'.freeze

  before_validation :downcase_domain
  validates :domain, uniqueness: { case_sensitive: false }
  validates :domain, format: { with: DOMAIN_REGEX, message: DOMAIN_MESSAGE }

  def self.allowed?(email_or_domain)
    domain = (email_or_domain.to_s.gsub(/^(.*)@/, '') || '').downcase
    !(domain.empty? || DenylistDomain.find_by(domain:))
  end

  def downcase_domain
    domain&.downcase!
  end
end
