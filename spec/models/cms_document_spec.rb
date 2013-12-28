require 'spec_helper'

describe CmsDocument do
  let(:invalid_document) { FactoryGirl.build(:cms_document, :page => '', :article => '') }
  it { invalid_document.should_not be_valid }

  describe '#packaged' do

  end
end
