class MauTweeter

  def tweet(msg)
    tw_client = setup_auth
    tw_client.statuses.update! :status => msg
  end

  private
  def setup_auth
    # these are the MAU app tokens
    # they tie us to the app that we created on dev.twitter.com as user sfmau
    # all this is fetched from http://dev.twitter.com
    #
    auth = { :type => :oauth,
      :consumer_key => 'V7Nif8IiVQnajQ3XUslwcg',
      :consumer_secret => 'UUvDXjUu6SK8DxrqwNNSYrcROYP0osMJmPUSOpxZ0',
      :token => '62131363-mPnEym1H3rBeA0wKnqNRAPMpSBr6UZOdLpUM7yx0W',
      :token_secret => 'XSDpwrfxRya6KHB3azNrtBKxG0hAjxJKJc8JGFRQhxQ'}

    Grackle::Client.new(:auth=>auth)
  end

end
