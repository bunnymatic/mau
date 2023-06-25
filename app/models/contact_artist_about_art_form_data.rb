class ContactArtistAboutArtFormData
  include ActiveModel::Model

  attr_accessor :email, :name, :phone, :message, :art_piece_id

  validates :email, format: { with: Mau::Regex::EMAIL, message: Mau::Regex::BAD_EMAIL_MESSAGE }, if: -> { email.present? }
  validates :phone, phone_number: true
  validates :name, presence: true
  validates :art_piece_id, presence: true
  validate :email_or_phone_present?

  def email_or_phone_present?
    return false unless email.blank? && phone.blank?

    msg = 'You must include either email or phone or both'
    errors.add('email', msg)
    errors.add('phone', msg)
  end

  def to_h
    %i[email name phone message art_piece_id].index_with do |key|
      send(key)
    end
  end
end
