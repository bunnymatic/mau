require 'rails_helper'

describe HtmlEncoder do
  let(:service) { described_class }

  describe '.encode' do
    it 'encodes html entities in the string' do
      q = HtmlEncoder.encode('encode me <> & _ @$# yo!')
      expect(q).to eql 'encode me &lt;&gt; &amp; _ @$# yo!'
    end
  end
end
