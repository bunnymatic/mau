# frozen_string_literal: true

require 'rails_helper'

describe Admin::DiscountController do
  let(:admin) { FactoryBot.create(:artist, :admin) }

  describe 'unauthorized' do
    before do
      get :markup
    end
    it_should_behave_like 'not authorized'
  end
  describe 'authorized' do
    before do
      login_as admin
    end
    context 'with good args' do
      before do
        get :markup, params: { markdown: "## mark it down\n\n * one\n * two\n\nok?\n\n" }
      end
      it 'handles markdown' do
        htm = response.body
        expect(htm).to include '<h2>mark it down</h2>'
        expect(htm).to include '<li>one</li>'
      end
    end
  end
end
