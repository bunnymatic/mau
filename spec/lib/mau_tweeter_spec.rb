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
      m = double(:statuses => double( :update! => 'go' ))
      Grackle::Client.should_receive(:new).exactly(:once).with(:auth => auth).and_return(m)
      MauTweeter.new.send(:tweet, stub(:message =>'give me pith or give me death'))
    end
    it 'tweets a message' do
      m = double "GrackleClient"
      Grackle::Client.any_instance.should_receive(:statuses).exactly(:once).and_return(m)
      m.should_receive(:update!).exactly(:once)
      MauTweeter.new.send(:tweet, double(:pithy_message =>'give me pith or give me death'))
    end
  end
end
