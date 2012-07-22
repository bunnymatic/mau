require "spec_helper"

describe MauTweeter do
  describe 'tweet' do
    it 'authenticates our twitter user' do
      auth = { :type => :oauth,
        :consumer_key => 'V7Nif8IiVQnajQ3XUslwcg',
        :consumer_secret => 'UUvDXjUu6SK8DxrqwNNSYrcROYP0osMJmPUSOpxZ0',
        :token => '62131363-mPnEym1H3rBeA0wKnqNRAPMpSBr6UZOdLpUM7yx0W',
        :token_secret => 'XSDpwrfxRya6KHB3azNrtBKxG0hAjxJKJc8JGFRQhxQ' 
      }
      m = stub(:statuses => stub( :update! => 'go' ))
      Grackle::Client.expects(:new).once.with(:auth => auth).returns(m)
      MauTweeter.new.send(:tweet, stub(:message =>'give me pith or give me death'))
    end
    it 'tweets a message' do
      m = mock "GrackleClient"
      Grackle::Client.any_instance.expects(:statuses).once.returns(m)
      m.expects(:update!).once
      MauTweeter.new.send(:tweet, stub(:pithy_message =>'give me pith or give me death'))
    end
  end
end
