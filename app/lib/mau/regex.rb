module Mau
  class Regex
    LOGIN = /\A\w[\w\-_.@]+\z/.freeze # ASCII, strict
    BAD_LOGIN_MESSAGE = 'should include only letters, numbers.  No whitespace or special characters.'.freeze

    EMAIL_NAME  = '[\w\.%\+\-]+'.freeze
    DOMAIN_HEAD = '(?:[A-Z0-9\-]+\.)+'.freeze
    DOMAIN_TLD  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum|me|ly)'.freeze
    EMAIL       = /\A#{EMAIL_NAME}@#{DOMAIN_HEAD}#{DOMAIN_TLD}\z/i.freeze
    BAD_EMAIL_MESSAGE = 'should look like an email address.'.freeze
  end
end
