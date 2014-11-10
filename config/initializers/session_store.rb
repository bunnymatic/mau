Mau::Application.configure do
  config.session_store :cookie_store, {
    :key => '_mauweb_session',
    :expire_after => 2.weeks
  }
  config.secret_token = '6c4c3b3cfb81db60efab3e21d6581d6761258c563f0a8ed11d9722a6f01d98f2c80cd669b92d3b02e9cf2a822f39c8bf2d'
end
