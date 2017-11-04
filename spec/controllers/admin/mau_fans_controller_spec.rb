# frozen_string_literal: true
require 'rails_helper'

describe Admin::MauFansController do
  let(:admin) { create :artist, :admin }
  describe '#index' do
    before do
      FactoryBot.create_list(:artist, 2, :active)
      FactoryBot.create_list(:mau_fan, 2, :active)
      login_as admin
      get :index
    end
    it { expect(response).to be_success }
    it 'assigns fans' do
      expect(assigns(:fans)).to have(2).fans
      expect(assigns(:fans).first).to be_a_kind_of UserPresenter
    end
  end
end
