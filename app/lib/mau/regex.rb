# frozen_string_literal: true
module Mau
  class Regex
    LOGIN = /\A\w[\w\.\-_@]+\z/ # ASCII, strict
    BAD_LOGIN_MESSAGE = 'should include only letters, numbers.  No whitespace or special characters.'

    EMAIL_NAME  = '[\w\.%\+\-]+'
    DOMAIN_HEAD = '(?:[A-Z0-9\-]+\.)+'
    DOMAIN_TLD  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|me|ly)'
    EMAIL       = /\A#{EMAIL_NAME}@#{DOMAIN_HEAD}#{DOMAIN_TLD}\z/i
    BAD_EMAIL_MESSAGE = 'should look like an email address.'
  end
end
