require 'spec_helper'

describe HTMLHelper do
  describe '.queryencode' do
    it 'encodes queries' do
      q = HTMLHelper::queryencode({:this => 'whatever', :that => 'with a space'})
      expect(q).to eql '?this=whatever&that=with+a+space'
    end
  end
end
