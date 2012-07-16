# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Scammer do
  fixtures :scammers
  before do
    test_data =<<EOM
{
"response":{
"status":"OK",
"code":"200",
"verb":"GET",
"class":"scammers",
"method":"get",
"adminid":"1",
"id":"",
"message":"OK",
"uri":"/1/scammers?key=2386ad2c89aa40dfa0ce90e868797a33&format=json",
"host":"api.faso.com",
"version":"1",
"ip":"70.36.223.19",
"location":"",
"level":"1"
},"data":{
"0":{
"id":"7443",
"email":"help@gotartwork.com",
"name_used":"Robert"
},"1":{
"id":"7441",
"email":"i.artguide@yahoo.com",
"name_used":"International Art Guide"
},"2":{
"id":"7439",
"email":"yulet@elanexpo.net",
"name_used":null
},"3":{
"id":"7437",
"email":"laurynsley@gmail.com",
"name_used":"Lauryn Masley"
}
}
}
EOM

    FakeWeb.register_uri(:get, Regexp.new( "https:\/\/api.faso.com\/1\/scammers*"), {:status => 200, :body => test_data})
  end
  describe '#importFromFASO' do
    it 'adds new data to the scammers list' do
      expect { Scammer.importFromFASO }.to change(Scammer, :count).by(4)
    end
    it 'called twice doesn\'t add anyone new' do
      Scammer.importFromFASO
      expect { Scammer.importFromFASO }.to change(Scammer, :count).by(0)
    end
    it 'entries are correct after import' do
      Scammer.importFromFASO
      Scammer.find_by_faso_id(7437).email.should == 'laurynsley@gmail.com'
    end
  end
  describe 'validations' do
    it 'doesn\'t allow duplicate faso_id entries' do
      faso_id = Scammer.first.faso_id
      Scammer.new(:faso_id => faso_id, :email => 'joe@example.com', :name => 'my name').should_not be_valid
    end
  end
end
