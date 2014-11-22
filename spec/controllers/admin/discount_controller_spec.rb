require 'spec_helper'

describe Admin::DiscountController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }

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
        get :markup, :markdown => "## mark it down\n\n * one\n * two\n\nok?\n\n"
      end
      it 'handles markdown' do
        htm = response.body
        htm.should include '<h2>mark it down</h2>'
        htm.should include '<li>one</li>'
      end
    end
  end
end