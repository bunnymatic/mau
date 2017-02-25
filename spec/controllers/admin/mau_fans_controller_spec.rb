# frozen_string_literal: true
require 'rails_helper'

describe Admin::MauFansController do
  let(:admin) { create :artist, :admin }
  describe '#index' do
    before do
      FactoryGirl.create_list(:artist, 2, :active)
      FactoryGirl.create_list(:mau_fan, 2, :active)
      login_as admin
      get :index
    end
    it { expect(response).to be_success }
    it 'assigns fans' do
      expect(assigns(:fans)).to have(2).fans
    end
  end
end
