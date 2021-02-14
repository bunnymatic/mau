require 'rails_helper'

describe CmsDocument do
  let(:invalid_document) { FactoryBot.build(:cms_document, page: '', article: '') }
  it { expect(invalid_document).not_to be_valid }

  describe '#packaged' do
  end
end
