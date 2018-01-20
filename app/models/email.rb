# frozen_string_literal: true

class Email < ApplicationRecord
  has_many :email_list_memberships, dependent: :destroy
  has_many :email_list, through: :email_list_membership
  validates :email, presence: true
  validates :email, format: { with: Mau::Regex::EMAIL, message: Mau::Regex::BAD_EMAIL_MESSAGE }

  def formatted
    name.present? ? "#{name} <#{email}>" : email
  end

  # def self.find_or_create props
  #   email = Email.new(props)
  #   found = Email.find_by_email(email.email)
  #   found ? found : email
  # end
end
