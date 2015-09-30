require 'spec_helper'

describe ViewPresenter do

  let(:simple_artist) { FactoryGirl.build(:artist) }
  subject(:presenter) { ViewPresenter.new }

  describe 'csv_safe' do
    it 'should clean the fields' do
      presenter.csv_safe( "eat@\#\$!!\"\', 123").should eql 'eat@#$!! 123'
    end
  end

end
