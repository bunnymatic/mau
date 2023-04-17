class Email < ApplicationRecord
  has_many :email_list_memberships
  has_many :email_lists, through: :email_list_memberships, dependent: :destroy

  validates :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: Mau::Regex::BAD_EMAIL_MESSAGE }

  def formatted
    name.present? ? "#{name} <#{email}>" : email
  end
end
