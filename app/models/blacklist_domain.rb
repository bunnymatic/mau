class BlacklistDomain < ActiveRecord::Base
  DOMAIN_REGEX = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}\z/
  DOMAIN_MESSAGE = "This domain does not appear to be valid."

  before_validation :downcase_domain
  validates_uniqueness_of :domain
  validates_format_of :domain, :with => DOMAIN_REGEX, :message =>  DOMAIN_MESSAGE

  def self.is_allowed?(email_or_domain)
    domain = (email_or_domain.to_s.gsub(/^(.*)\@/, '') || '').downcase
    !(domain.empty? || BlacklistDomain.where(:domain => domain).first)
  end

  def downcase_domain
    domain.downcase! if domain
  end
end
