# Authlogic user session model
class UserSession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  generalize_credentials_error_messages I18n.t("authlogic.error_messages.generalize_credentials_error_messages")

  find_by_login_method :find_by_login_or_email
end

