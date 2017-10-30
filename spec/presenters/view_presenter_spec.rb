# frozen_string_literal: true
require 'rails_helper'

describe ViewPresenter do
  let(:simple_artist) { FactoryBot.build(:artist) }
  subject(:presenter) { ViewPresenter.new }

  describe 'csv_safe' do
    it 'should clean the fields' do
      expect(presenter.csv_safe("eat@\#\$!!\"\', 123")).to eql 'eat@#$!! 123'
    end
  end
end
