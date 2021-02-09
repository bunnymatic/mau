# frozen_string_literal: true

module PhoneNumberMixin
  def normalize_phone_number(phone)
    phone&.gsub(/\D+/, '')
  end
end
