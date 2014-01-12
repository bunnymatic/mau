require 'spec_helper'

describe UsersHelper do

  let(:rendered) { HTML::Document.new(generated).root }
  let(:spanner) { content_tag('span', 'stuff') }
  describe '_label' do
    let(:generated) {
      helper._label { spanner }
    }
    it 'includes a label wrapper div' do
      assert_select(rendered, '.label span', :text => 'stuff')
    end
  end

  describe '_input' do
    let(:generated) {
      helper._input { spanner }
    }
    it 'includes an input wrapper div' do
      assert_select(rendered, '.input span', :text => 'stuff')
    end
  end

end
