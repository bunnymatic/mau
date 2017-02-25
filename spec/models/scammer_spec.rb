# -*- coding: utf-8 -*-
# frozen_string_literal: true
require 'rails_helper'

describe Scammer do
  before do
    test_data =<<EOM
"id"|"email"|"name_used"
"7445"|"gatecharles73@gmail.com"|"Charles Gate"
"7441"|"i.artguide@yahoo.com"|"International Art Guide"
"7439"|"yulet@elanexpo.net"|"Yulet T<FC>ren"
"7437"|"laurynsley@gmail.com"|"Lauryn Masley"
EOM

    stub_request(:get, Regexp.new( "https:\/\/api.faso.com\/1\/scammers*"))
      .to_return(status: 200, body: test_data)
    FactoryGirl.create_list(:scammer, 2)
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
      expect(Scammer.find_by_faso_id('7437').email).to eq('laurynsley@gmail.com')
    end
  end
  describe 'validations' do
    it 'doesn\'t allow duplicate faso_id entries' do
      faso_id = Scammer.first.faso_id
      expect(Scammer.new(faso_id: faso_id, email: 'joe@example.com', name: 'my name')).not_to be_valid
    end
  end
end
