# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_mau_session', domain: :all, tld_length: Integer(Conf.TLD_LENGTH || 1)
