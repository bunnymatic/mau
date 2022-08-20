require 'rails_helper'

describe MauImage::Paperclip do
  describe '.variant_args' do
    it 'returns args for a known size as a symbol' do
      expect(described_class.variant_args(:small)).to be_present
    end
    it 'returns args for a known size as a string' do
      expect(described_class.variant_args('small')).to be_present
    end
    it 'raises a sensible error when an unknown variant is requested' do
      expect { described_class.variant_args('even_bigger') }.to raise_error MauImage::Paperclip::InvalidVariantError
    end
  end
end
